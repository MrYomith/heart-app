"""Storage abstraction: local backend round-trip + legacy absolute-path reads."""
import os

from app.core.storage import LocalStorage


def test_local_storage_round_trip(tmp_path):
    s = LocalStorage(root=tmp_path)
    ref = s.save("wound/x.jpg", b"bytes", content_type="image/jpeg")
    assert ref == "wound/x.jpg"          # relative key stored, not absolute path
    assert s.exists(ref)
    assert s.read(ref) == b"bytes"
    s.delete(ref)
    assert not s.exists(ref)
    assert s.read(ref) is None


def test_local_storage_reads_legacy_absolute_path(tmp_path):
    s = LocalStorage(root=tmp_path)
    s.save("a/b.txt", b"hello")
    abs_path = os.path.join(tmp_path, "a", "b.txt")
    # Older DB rows stored an absolute path; reads must still resolve them.
    assert s.read(abs_path) == b"hello"
    assert s.exists(abs_path)
