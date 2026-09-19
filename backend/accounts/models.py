from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    """Creates users with email as the login identifier.

    Pass ``password=None`` for Google-only accounts; they get an unusable password.
    """

    use_in_migrations = True

    def _create_user(self, email, password, **extra_fields):
        if not email:
            raise ValueError("Email is required")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_user(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(email, password, **extra_fields)

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        return self._create_user(email, password, **extra_fields)


class User(AbstractUser):
    """Account that owns conversations.

    Login is email, not username. Inherits Django's password, staff, and
    permission fields from AbstractUser.

    Schema:
        id              BigAutoField PK
        email           unique, USERNAME_FIELD
        display_name    shown in the UI; defaults to the email local-part
        google_sub      unique Google subject; null until Google sign-in
        password        hashed; unusable when the user is Google-only
        is_staff / is_superuser / is_active / date_joined / last_login
    """

    username = None
    email = models.EmailField(
        unique=True,
        help_text="Login identifier. Normalized to lowercase on create.",
    )
    display_name = models.CharField(
        max_length=150,
        blank=True,
        help_text="Name shown in chat. Filled from the email local-part if blank.",
    )
    google_sub = models.CharField(
        max_length=255,
        unique=True,
        null=True,
        blank=True,
        help_text="Google Identity Services `sub`. Links GIS sign-in to this row.",
    )

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return self.email

    def save(self, *args, **kwargs):
        if not self.display_name:
            self.display_name = self.email.split("@")[0]
        super().save(*args, **kwargs)
