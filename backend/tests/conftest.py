import pytest
from django.contrib.auth import get_user_model

User = get_user_model()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        email="ada@example.com",
        password="correct-horse-battery",
        display_name="Ada",
    )


@pytest.fixture
def other_user(db):
    return User.objects.create_user(
        email="grace@example.com",
        password="correct-horse-battery",
        display_name="Grace",
    )
