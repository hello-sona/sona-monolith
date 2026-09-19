from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Conversation
from .serializers import (
    ConversationSerializer,
    MessageSerializer,
    SendMessageSerializer,
)
from .services import send_user_message


class ConversationViewSet(viewsets.ModelViewSet):
    serializer_class = ConversationSerializer
    http_method_names = ["get", "post", "patch", "delete", "head", "options"]

    def get_queryset(self):
        return Conversation.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=["get", "post"])
    def messages(self, request, pk=None):
        conversation = self.get_object()
        if request.method == "GET":
            messages = conversation.messages.all()
            return Response(MessageSerializer(messages, many=True).data)

        serializer = SendMessageSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user_message, assistant_message = send_user_message(
            conversation, serializer.validated_data["content"]
        )
        conversation.refresh_from_db()
        return Response(
            {
                "user_message": MessageSerializer(user_message).data,
                "assistant_message": MessageSerializer(assistant_message).data,
                "conversation": ConversationSerializer(conversation).data,
            },
            status=status.HTTP_201_CREATED,
        )
