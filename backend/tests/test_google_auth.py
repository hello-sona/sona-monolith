from unittest.mock import patch

import pytest
from django.contrib.auth import get_user_model
from django.test import override_settings
from rest_framework.test import APIClient

from accounts.google import GoogleCredentialError

User = get_user_model()

pytestmark = pytest.mark.django_db

GOOGLE_PAYLOAD = {
    "sub": "google-sub-123",
    "email": "ada@gmail.com",
    "email_verified": True,
    "name": "Ada Lovelace",
}


@pytest.fixture
def api():
    return APIClient()


@patch("accounts.services.verify_google_credential", return_value=GOOGLE_PAYLOAD)
def test_google_creates_user_and_starts_session(mock_verify, api):
    response = api.post("/api/auth/google/", {"credential": "fake-token"}, format="json")

    assert response.status_code == 201
    assert response.data["email"] == "ada@gmail.com"
    assert response.data["display_name"] == "Ada Lovelace"
    mock_verify.assert_called_once_with("fake-token")

    user = User.objects.get(email="ada@gmail.com")
    assert user.google_sub == "google-sub-123"
    assert not user.has_usable_password()

    me = api.get("/api/auth/me/")
    assert me.status_code == 200
    assert me.data["email"] == "ada@gmail.com"


@patch("accounts.services.verify_google_credential", return_value=GOOGLE_PAYLOAD)
def test_google_logs_in_existing_google_user(mock_verify, api):
    User.objects.create_user(
        email="ada@gmail.com",
        password=None,
        display_name="Ada",
        google_sub="google-sub-123",
    )

    response = api.post("/api/auth/google/", {"credential": "fake-token"}, format="json")

    assert response.status_code == 200
    assert User.objects.filter(email="ada@gmail.com").count() == 1
    assert api.get("/api/auth/me/").status_code == 200


@patch("accounts.services.verify_google_credential", return_value=GOOGLE_PAYLOAD)
def test_google_links_existing_email_account(mock_verify, api, user):
    user.email = "ada@gmail.com"
    user.save(update_fields=["email"])

    response = api.post("/api/auth/google/", {"credential": "fake-token"}, format="json")

    assert response.status_code == 200
    user.refresh_from_db()
    assert user.google_sub == "google-sub-123"
    assert user.has_usable_password()
    assert api.get("/api/auth/me/").data["email"] == "ada@gmail.com"


@patch(
    "accounts.services.verify_google_credential",
    side_effect=GoogleCredentialError("Invalid Google credential."),
)
def test_google_rejects_invalid_token(mock_verify, api):
    response = api.post("/api/auth/google/", {"credential": "bad"}, format="json")
    assert response.status_code == 400
    assert response.data["detail"] == "Invalid Google credential."


@override_settings(GOOGLE_CLIENT_ID="")
def test_google_requires_configuration(api):
    response = api.post("/api/auth/google/", {"credential": "fake-token"}, format="json")
    assert response.status_code == 503
    assert "not configured" in response.data["detail"]
