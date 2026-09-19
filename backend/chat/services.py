from .models import Conversation, Message


def derive_title(content: str) -> str:
    first_line = content.strip().splitlines()[0]
    if len(first_line) <= 72:
        return first_line
    return first_line[:72].rstrip() + "…"


def generate_reply(content: str) -> str:
    excerpt = content.strip()
    if len(excerpt) > 400:
        excerpt = excerpt[:400].rstrip() + "…"
    return (
        "I'm Sona's local stand-in until a model is wired up. "
        f"You said: {excerpt}"
    )


def send_user_message(conversation: Conversation, content: str) -> tuple[Message, Message]:
    user_message = Message.objects.create(
        conversation=conversation,
        role=Message.Role.USER,
        content=content,
    )
    assistant_message = Message.objects.create(
        conversation=conversation,
        role=Message.Role.ASSISTANT,
        content=generate_reply(content),
    )
    update_fields = ["updated_at"]
    if conversation.title == "New chat":
        conversation.title = derive_title(content)
        update_fields.append("title")
    conversation.save(update_fields=update_fields)
    return user_message, assistant_message
