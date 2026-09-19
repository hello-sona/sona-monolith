import pytest
from rest_framework.test import APIClient

from accounts.seed import TEST_USER_EMAIL, TEST_USER_PASSWORD, seed_test_user

pytestmark = pytest.mark.django_db


@pytest.fixture
def api():
    return APIClient()


def test_register_creates_user_and_starts_session(api):
    response = api.post(
        "/api/auth/register/",
        {"email": "new@example.com", "password": "correct-horse-battery", "display_name": "New"},
        format="json",
    )

    assert response.status_code == 201
    assert response.data["email"] == "new@example.com"
    assert response.data["display_name"] == "New"

    me = api.get("/api/auth/me/")
    assert me.status_code == 200
    assert me.data["email"] == "new@example.com"


def test_register_normalizes_email(api):
    response = api.post(
        "/api/auth/register/",
        {"email": "  MixEd@Example.COM ", "password": "correct-horse-battery"},
        format="json",
    )

    assert response.status_code == 201
    assert response.data["email"] == "mixed@example.com"
    assert response.data["display_name"] == "mixed"


def test_login_and_logout(api, user):
    bad = api.post(
        "/api/auth/login/",
        {"email": user.email, "password": "wrong-password"},
        format="json",
    )
    assert bad.status_code == 400

    ok = api.post(
        "/api/auth/login/",
        {"email": user.email, "password": "correct-horse-battery"},
        format="json",
    )
    assert ok.status_code == 200
    assert ok.data["email"] == user.email

    me = api.get("/api/auth/me/")
    assert me.status_code == 200

    logout = api.post("/api/auth/logout/")
    assert logout.status_code == 204

    me_again = api.get("/api/auth/me/")
    assert me_again.status_code in (401, 403)


def test_seeded_admin_can_sign_in_with_short_name(api):
    seed_test_user()
    response = api.post(
        "/api/auth/login/",
        {"email": "admin", "password": TEST_USER_PASSWORD},
        format="json",
    )

    assert response.status_code == 200
    assert response.data["email"] == TEST_USER_EMAIL
    assert response.data["display_name"] == "admin"


def test_me_requires_authentication(api):
    response = api.get("/api/auth/me/")
    assert response.status_code in (401, 403)


def test_csrf_sets_cookie(api):
    response = api.get("/api/auth/csrf/")
    assert response.status_code == 200
    assert "csrfToken" in response.data
    assert "csrftoken" in response.cookies
