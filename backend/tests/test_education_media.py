"""Education media_url surfacing: external URLs go straight to the client,
uploaded files stream via our route, missing media returns null."""
from app.enums import ContentType
from app.models import EducationContent
from app.routers.education import _out


def _row(s3_key):
    return EducationContent(title="t", type=ContentType.video, s3_key=s3_key)


def test_external_http_media_is_returned_directly():
    url = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    assert _out(_row(url))["media_url"] == url


def test_uploaded_file_streams_via_route():
    out = _out(_row("education/abc.mp4"))
    assert out["media_url"].startswith("/api/education/media/")


def test_no_media_is_null():
    assert _out(_row(None))["media_url"] is None
