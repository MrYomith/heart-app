"""Swappable object storage (NFR-040 data handling).

One interface, two backends chosen by the STORAGE_BACKEND env var:
  - "local" (default): files under backend/uploads/  — fine for dev / single host.
  - "s3": an S3 (or S3-compatible) bucket — for production / GDPR-region storage.

Routers store the value returned by `save()` in the DB (the `s3_key` column) and pass
it back to `read()`/`url()`/`delete()`. They never touch the filesystem or boto3
directly, so switching backends is a config change, not a code change.

Backward compatibility: older rows stored an absolute filesystem path in s3_key.
`read()`/`exists()` detect that and still serve those files.
"""
from __future__ import annotations

import os
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Optional

_BACKEND_ROOT = Path(__file__).resolve().parents[2]  # backend/
_UPLOAD_ROOT = _BACKEND_ROOT / "uploads"


class StorageBackend(ABC):
    @abstractmethod
    def save(self, key: str, data: bytes, content_type: str = "application/octet-stream") -> str:
        """Persist bytes under a logical key (e.g. 'wound/abc.jpg'). Returns the
        reference string to store in the DB and pass back to read()/url()/delete()."""

    @abstractmethod
    def read(self, ref: str) -> Optional[bytes]:
        """Return the stored bytes, or None if the object is missing."""

    @abstractmethod
    def exists(self, ref: str) -> bool:
        ...

    @abstractmethod
    def delete(self, ref: str) -> None:
        ...

    def url(self, ref: str) -> Optional[str]:
        """A directly fetchable URL if the backend supports it (e.g. S3 presigned);
        None means the caller should stream bytes via read() instead."""
        return None


class LocalStorage(StorageBackend):
    """Files on the local filesystem under backend/uploads/<key>."""

    def __init__(self, root: Path = _UPLOAD_ROOT):
        self.root = root

    def _path(self, ref: str) -> Path:
        # Legacy rows stored an absolute path; honour it as-is.
        if os.path.isabs(ref):
            return Path(ref)
        return self.root / ref

    def save(self, key: str, data: bytes, content_type: str = "application/octet-stream") -> str:
        path = self._path(key)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        return key  # store the relative key, not the absolute path

    def read(self, ref: str) -> Optional[bytes]:
        path = self._path(ref)
        if not path.exists():
            return None
        return path.read_bytes()

    def exists(self, ref: str) -> bool:
        return self._path(ref).exists()

    def delete(self, ref: str) -> None:
        path = self._path(ref)
        if path.exists():
            path.unlink()


class S3Storage(StorageBackend):
    """S3 / S3-compatible bucket. boto3 is imported lazily so it isn't a hard
    dependency for local-only deployments."""

    def __init__(self, bucket: str, region: str, endpoint_url: Optional[str] = None):
        import boto3  # lazy

        self.bucket = bucket
        self._client = boto3.client("s3", region_name=region, endpoint_url=endpoint_url)

    def _key(self, ref: str) -> str:
        # Tolerate refs saved as "s3://bucket/key".
        if ref.startswith("s3://"):
            return ref.split("/", 3)[-1]
        return ref

    def save(self, key: str, data: bytes, content_type: str = "application/octet-stream") -> str:
        self._client.put_object(
            Bucket=self.bucket, Key=key, Body=data,
            ContentType=content_type, ServerSideEncryption="AES256",
        )
        return key

    def read(self, ref: str) -> Optional[bytes]:
        try:
            obj = self._client.get_object(Bucket=self.bucket, Key=self._key(ref))
            return obj["Body"].read()
        except Exception:
            return None

    def exists(self, ref: str) -> bool:
        try:
            self._client.head_object(Bucket=self.bucket, Key=self._key(ref))
            return True
        except Exception:
            return False

    def delete(self, ref: str) -> None:
        try:
            self._client.delete_object(Bucket=self.bucket, Key=self._key(ref))
        except Exception:
            pass

    def url(self, ref: str) -> Optional[str]:
        try:
            return self._client.generate_presigned_url(
                "get_object",
                Params={"Bucket": self.bucket, "Key": self._key(ref)},
                ExpiresIn=3600,
            )
        except Exception:
            return None


def _build_backend() -> StorageBackend:
    backend = os.getenv("STORAGE_BACKEND", "local").strip().lower()
    if backend == "s3":
        bucket = os.getenv("S3_BUCKET", "").strip()
        if not bucket:
            raise RuntimeError("STORAGE_BACKEND=s3 requires S3_BUCKET to be set.")
        region = os.getenv("S3_REGION", "eu-central-1").strip()
        endpoint = os.getenv("S3_ENDPOINT_URL", "").strip() or None
        return S3Storage(bucket=bucket, region=region, endpoint_url=endpoint)
    return LocalStorage()


# Module-level singleton used by the routers.
storage: StorageBackend = _build_backend()
