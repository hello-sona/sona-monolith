from django.core.management.base import BaseCommand

from accounts.seed import TEST_USER_EMAIL, TEST_USER_LOGIN, TEST_USER_PASSWORD, seed_test_user


class Command(BaseCommand):
    help = "Create or reset the local admin test user."

    def handle(self, *args, **options):
        user, created = seed_test_user()
        action = "Created" if created else "Updated"
        self.stdout.write(
            self.style.SUCCESS(
                f"{action} test user {user.email}. "
                f"Sign in with {TEST_USER_LOGIN} or {TEST_USER_EMAIL} / {TEST_USER_PASSWORD}."
            )
        )
