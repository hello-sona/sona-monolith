from django.contrib.auth import get_user_model

from .google import verify_google_credential

User = get_user_model()


def resolve_login_email(identifier: str) -> str:
    value = identifier.strip().lower()
    if "@" in value:
        return value

    by_local_part = User.objects.filter(email__iexact=f"{value}@example.com").first()
    if by_local_part:
        return by_local_part.email

    by_name = User.objects.filter(display_name__iexact=identifier.strip()).first()
    if by_name:
        return by_name.email

    return value


def get_or_create_google_user(payload: dict) -> tuple[User, bool]:
    email = payload["email"].lower().strip()
    sub = payload["sub"]
    name = (payload.get("name") or payload.get("given_name") or "").strip()

    user = User.objects.filter(google_sub=sub).first()
    if user:
        return user, False

    user = User.objects.filter(email__iexact=email).first()
    if user:
        user.google_sub = sub
        update_fields = ["google_sub"]
        if name and user.display_name in {"", user.email.split("@")[0]}:
            user.display_name = name
            update_fields.append("display_name")
        user.save(update_fields=update_fields)
        return user, False

    user = User.objects.create_user(
        email=email,
        password=None,
        display_name=name,
        google_sub=sub,
    )
    return user, True


def authenticate_google(credential: str) -> tuple[User, bool]:
    payload = verify_google_credential(credential)
    return get_or_create_google_user(payload)
