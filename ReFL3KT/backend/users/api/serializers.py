from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.models import User
from ..models import UserProfile

class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for user registration with password confirmation
    """
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    phone_number = serializers.CharField(max_length=15, required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'phone_number', 'password', 'password_confirm')
        extra_kwargs = {
            'password': {'write_only': True},
            'id': {'read_only': True}
        }
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Passwords don't match")
        return attrs
    
    def create(self, validated_data):
        phone_number = validated_data.pop('phone_number', '')
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        
        # Create user profile with phone number
        UserProfile.objects.create(user=user, phone_number=phone_number)
        return user

class UserLoginSerializer(serializers.Serializer):
    """
    Serializer for user login
    """
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')
        
        if username and password:
            user = authenticate(username=username, password=password)
            if not user:
                raise serializers.ValidationError('Invalid credentials')
            if not user.is_active:
                raise serializers.ValidationError('User account is disabled')
            attrs['user'] = user
            return attrs
        else:
            raise serializers.ValidationError('Must include username and password')

class UserSerializer(serializers.ModelSerializer):
    """
    Serializer for user data representation
    """
    profile = serializers.SerializerMethodField()
    phone_number = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'phone_number', 'date_joined', 'is_active', 'profile')
        read_only_fields = ('id', 'date_joined', 'is_active')
    
    def get_phone_number(self, obj):
        try:
            return obj.profile.phone_number
        except UserProfile.DoesNotExist:
            return None
    
    def get_profile(self, obj):
        try:
            profile = obj.profile
            return {
                'phone_number': profile.phone_number,
                'bio': profile.bio,
                'avatar': profile.avatar,
                'timezone': profile.timezone,
                'is_verified': profile.is_verified,
                'created_at': profile.created_at,
                'updated_at': profile.updated_at
            }
        except UserProfile.DoesNotExist:
            return None

class UserCreateSerializer(serializers.ModelSerializer):
    """
    Simplified serializer for creating users
    """
    password = serializers.CharField(write_only=True, validators=[validate_password])
    phone_number = serializers.CharField(max_length=15, required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'phone_number', 'password')
        extra_kwargs = {
            'password': {'write_only': True},
            'id': {'read_only': True}
        }
    
    def create(self, validated_data):
        phone_number = validated_data.pop('phone_number', '')
        user = User.objects.create_user(**validated_data)
        UserProfile.objects.create(user=user, phone_number=phone_number)
        return user

class UserUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating user information
    """
    phone_number = serializers.CharField(max_length=15, required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = ('first_name', 'last_name', 'email', 'phone_number')
    
    def update(self, instance, validated_data):
        phone_number = validated_data.pop('phone_number', None)
        
        # Update user fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Update phone number in profile
        if phone_number is not None:
            profile, created = UserProfile.objects.get_or_create(user=instance)
            profile.phone_number = phone_number
            profile.save()
        
        return instance

class ChangePasswordSerializer(serializers.Serializer):
    """
    Serializer for changing user password
    """
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    new_password_confirm = serializers.CharField(write_only=True)
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError("New passwords don't match")
        return attrs
    
    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect")
        return value

class UserProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for user profile data
    """
    user_id = serializers.IntegerField(source='user.id', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = UserProfile
        fields = ('user_id', 'username', 'bio', 'avatar', 'timezone', 'created_at', 'updated_at')
        read_only_fields = ('created_at', 'updated_at')
