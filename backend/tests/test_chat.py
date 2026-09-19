import pytest
from rest_framework.test import APIClient

from chat.models import Conversation, Message

pytestmark = pytest.mark.django_db


@pytest.fixture
def api(user):
    client = APIClient()
    client.force_login(user)
    return client


def test_conversation_crud_is_scoped_to_owner(api, user, other_user):
    create = api.post("/api/conversations/", {"title": "Planning"}, format="json")
    assert create.status_code == 201
    conversation_id = create.data["id"]

    listing = api.get("/api/conversations/")
    assert listing.status_code == 200
    assert len(listing.data) == 1
    assert listing.data[0]["title"] == "Planning"

    Conversation.objects.create(user=other_user, title="Someone else")
    listing = api.get("/api/conversations/")
    assert [item["title"] for item in listing.data] == ["Planning"]

    detail = api.get(f"/api/conversations/{conversation_id}/")
    assert detail.status_code == 200

    rename = api.patch(
        f"/api/conversations/{conversation_id}/",
        {"title": "Renamed"},
        format="json",
    )
    assert rename.status_code == 200
    assert rename.data["title"] == "Renamed"

    delete = api.delete(f"/api/conversations/{conversation_id}/")
    assert delete.status_code == 204
    assert not Conversation.objects.filter(id=conversation_id).exists()


def test_cannot_read_another_users_conversation(api, other_user):
    conversation = Conversation.objects.create(user=other_user, title="Private")
    response = api.get(f"/api/conversations/{conversation.id}/")
    assert response.status_code == 404


def test_send_message_creates_user_and_assistant_turns(api):
    created = api.post("/api/conversations/", {}, format="json")
    conversation_id = created.data["id"]
    assert created.data["title"] == "New chat"

    empty = api.post(
        f"/api/conversations/{conversation_id}/messages/",
        {"content": "   "},
        format="json",
    )
    assert empty.status_code == 400

    sent = api.post(
        f"/api/conversations/{conversation_id}/messages/",
        {"content": "How do sessions work?"},
        format="json",
    )
    assert sent.status_code == 201
    assert sent.data["user_message"]["role"] == "user"
    assert sent.data["user_message"]["content"] == "How do sessions work?"
    assert sent.data["assistant_message"]["role"] == "assistant"
    assert "How do sessions work?" in sent.data["assistant_message"]["content"]
    assert sent.data["conversation"]["title"] == "How do sessions work?"

    history = api.get(f"/api/conversations/{conversation_id}/messages/")
    assert history.status_code == 200
    assert [message["role"] for message in history.data] == ["user", "assistant"]

    listing = api.get("/api/conversations/")
    assert listing.data[0]["title"] == "How do sessions work?"


def test_later_messages_do_not_overwrite_title(api):
    created = api.post("/api/conversations/", {}, format="json")
    conversation_id = created.data["id"]
    api.post(
        f"/api/conversations/{conversation_id}/messages/",
        {"content": "First question"},
        format="json",
    )
    api.post(
        f"/api/conversations/{conversation_id}/messages/",
        {"content": "Follow up"},
        format="json",
    )

    conversation = Conversation.objects.get(id=conversation_id)
    assert conversation.title == "First question"
    assert conversation.messages.count() == 4
    assert Message.objects.filter(conversation=conversation, role="user").count() == 2
