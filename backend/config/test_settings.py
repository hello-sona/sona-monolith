import os

os.environ.setdefault("DJANGO_SECRET_KEY", "insecure-test-secret-key")

from .settings import *

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

GOOGLE_CLIENT_ID = "test-google-client.apps.googleusercontent.com"
