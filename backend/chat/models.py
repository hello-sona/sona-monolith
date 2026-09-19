import uuid

from django.conf import settings
from django.db import models


class Conversation(models.Model):
    """One chat thread owned by a user.

    Schema:
        id           UUID PK
        user_id      FK → User, cascade delete
        title        sidebar label; starts as "New chat", then first message
        created_at   set on insert
        updated_at   bumped when a message is added or the title is renamed

    Listed newest-updated first. Indexed on (user, -updated_at).
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="conversations",
        help_text="Owner. Deleting the user removes their threads.",
    )
    title = models.CharField(
        max_length=200,
        default="New chat",
        help_text="Sidebar title. Derived from the first user message if still default.",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-updated_at"]
        indexes = [
            models.Index(fields=["user", "-updated_at"]),
        ]

    def __str__(self):
        return self.title


class Message(models.Model):
    """One turn in a conversation.

    Schema:
        id               UUID PK
        conversation_id  FK → Conversation, cascade delete
        role             user | assistant | system
        content          message body
        created_at       set on insert; thread order

    `system` is reserved for a later model. The stub writer only creates
    user and assistant rows. Indexed on (conversation, created_at).
    """

    class Role(models.TextChoices):
        USER = "user", "User"
        ASSISTANT = "assistant", "Assistant"
        SYSTEM = "system", "System"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(
        Conversation,
        on_delete=models.CASCADE,
        related_name="messages",
        help_text="Parent thread. Deleting the conversation removes its messages.",
    )
    role = models.CharField(
        max_length=16,
        choices=Role.choices,
        help_text="Who produced this turn.",
    )
    content = models.TextField(help_text="Plain-text body of the turn.")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]
        indexes = [
            models.Index(fields=["conversation", "created_at"]),
        ]

    def __str__(self):
        return f"{self.role}: {self.content[:40]}"
