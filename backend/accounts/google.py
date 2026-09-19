from django.conf import settings
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token


class GoogleCredentialError(Exception):
    pass


def verify_google_credential(credential: str) -> dict:
    client_id = settings.GOOGLE_CLIENT_ID
    if not client_id:
        raise GoogleCredentialError("Google sign-in is not configured.")

    try:
        payload = id_token.verify_oauth2_token(
            credential,
            google_requests.Request(),
            audience=client_id,
        )
    except ValueError as exc:
        raise GoogleCredentialError("Invalid Google credential.") from exc

    issuer = payload.get("iss")
    if issuer not in {"accounts.google.com", "https://accounts.google.com"}:
        raise GoogleCredentialError("Invalid Google credential.")
    if not payload.get("email_verified"):
        raise GoogleCredentialError("Google email is not verified.")
    if not payload.get("email") or not payload.get("sub"):
        raise GoogleCredentialError("Invalid Google credential.")
    return payload
