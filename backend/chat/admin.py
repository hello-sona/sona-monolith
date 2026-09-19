from django.contrib import admin

from .models import Conversation, Message


class MessageInline(admin.TabularInline):
    model = Message
    extra = 0
    readonly_fields = ("id", "role", "content", "created_at")


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    list_display = ("title", "user", "updated_at")
    list_filter = ("updated_at",)
    search_fields = ("title", "user__email")
    inlines = [MessageInline]


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ("role", "conversation", "created_at")
    list_filter = ("role",)
    search_fields = ("content",)
