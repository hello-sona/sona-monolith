from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "display_name"]
        read_only_fields = fields


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ["email", "password", "display_name"]
        extra_kwargs = {"display_name": {"required": False, "allow_blank": True}}

    def validate_email(self, value):
        return value.lower().strip()

    def validate_password(self, value):
        validate_password(
            value,
            user=User(email=self.initial_data.get("email", "")),
        )
        return value

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class LoginSerializer(serializers.Serializer):
    email = serializers.CharField()
    password = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate_email(self, value):
        return value.strip()


class GoogleAuthSerializer(serializers.Serializer):
    credential = serializers.CharField()
