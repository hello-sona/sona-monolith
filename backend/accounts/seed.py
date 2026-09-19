from django.contrib.auth import get_user_model

TEST_USER_EMAIL = "admin@example.com"
TEST_USER_LOGIN = "admin"
TEST_USER_PASSWORD = "password!123"
TEST_USER_NAME = "admin"

User = get_user_model()


def seed_test_user():
    user, created = User.objects.get_or_create(
        email=TEST_USER_EMAIL,
        defaults={
            "display_name": TEST_USER_NAME,
            "is_staff": True,
            "is_superuser": True,
        },
    )
    user.display_name = TEST_USER_NAME
    user.is_staff = True
    user.is_superuser = True
    user.is_active = True
    user.set_password(TEST_USER_PASSWORD)
    user.save()
    return user, created
