from rest_framework import serializers
from django.contrib.auth import authenticate

from .models import CustomUser

class CustomAccountSerializer(serializers.ModelSerializer):
    date_joined = serializers.ReadOnlyField()
    class Meta:
        model = CustomUser
        fields = ('id', 'username', 'email', 'date_joined', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        return CustomUser.objects.create_user(**validated_data)
    
class CustomUserLoginSerializer(serializers.Serializer):
    """
    Serializer class to authenticate users with email and password.
    """

    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Incorrect Credentials")
