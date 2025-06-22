from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token
from django.contrib.auth import login, logout
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from django.db.models import Q
from ..models import UserProfile
from .serializers import (
    UserRegistrationSerializer, 
    UserLoginSerializer, 
    UserSerializer, 
    UserCreateSerializer,
    UserUpdateSerializer,
    ChangePasswordSerializer,
    UserProfileSerializer
)

# Authentication APIs
@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    """
    Register a new user
    POST /api/auth/register/
    Body: {
        "username": "string",
        "email": "string",
        "first_name": "string",
        "last_name": "string", 
        "phone_number": "string",
        "password": "string",
        "password_confirm": "string"
    }
    """
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        # Generate authentication token
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'User registered successfully',
            'user': UserSerializer(user).data,
            'token': token.key,
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    """
    Login user and return authentication token
    POST /api/auth/login/
    Body: {
        "username": "string",
        "password": "string"
    }
    """
    serializer = UserLoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        login(request, user)
        
        # Generate authentication token
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'Login successful',
            'user': UserSerializer(user).data,
            'token': token.key,
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_user(request):
    """
    Logout user and delete authentication token
    POST /api/auth/logout/
    Headers: Authorization: Token <token>
    """
    try:
        # Delete the user's token
        request.user.auth_token.delete()
        logout(request)
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': 'Logout failed'}, status=status.HTTP_400_BAD_REQUEST)

# User Management APIs
@api_view(['GET'])
@permission_classes([AllowAny])  # You might want to change this to IsAuthenticated for security
def get_all_users(request):
    """
    Get all users
    GET /api/auth/users/
    Query params:
    - search: search by username, first_name, last_name, email
    - limit: limit number of results
    """
    users = User.objects.all()
    
    # Search functionality
    search = request.GET.get('search')
    if search:
        users = users.filter(
            Q(username__icontains=search) |
            Q(first_name__icontains=search) |
            Q(last_name__icontains=search) |
            Q(email__icontains=search)
        )
    
    # Limit results
    limit = request.GET.get('limit')
    if limit:
        try:
            limit = int(limit)
            users = users[:limit]
        except ValueError:
            pass
    
    serializer = UserSerializer(users, many=True)
    return Response({
        'users': serializer.data,
        'count': users.count()
    }, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_user_by_id(request, user_id):
    """
    Get user by ID
    GET /api/auth/users/{user_id}/
    """
    try:
        user = get_object_or_404(User, id=user_id)
        serializer = UserSerializer(user)
        return Response({
            'user': serializer.data
        }, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([AllowAny])  # You might want to change this based on your requirements
def create_user(request):
    """
    Create a new user (simplified version without password confirmation)
    POST /api/auth/users/
    Body: {
        "username": "string",
        "email": "string",
        "first_name": "string",
        "last_name": "string",
        "phone_number": "string",
        "password": "string"
    }
    """
    serializer = UserCreateSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({
            'message': 'User created successfully',
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_current_user(request):
    """
    Get current authenticated user
    GET /api/auth/me/
    Headers: Authorization: Token <token>
    """
    serializer = UserSerializer(request.user)
    return Response({
        'user': serializer.data
    }, status=status.HTTP_200_OK)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_user(request, user_id=None):
    """
    Update user information
    PUT /api/auth/users/{user_id}/ (for admin)
    PUT /api/auth/me/update/ (for current user)
    Headers: Authorization: Token <token>
    Body: {
        "first_name": "string",
        "last_name": "string",
        "email": "string",
        "phone_number": "string"
    }
    """
    if user_id:
        # Update specific user (admin functionality)
        user = get_object_or_404(User, id=user_id)
        # Add permission check here if needed
    else:
        # Update current user
        user = request.user
    
    serializer = UserUpdateSerializer(user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response({
            'message': 'User updated successfully',
            'user': UserSerializer(user).data
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """
    Change user password
    POST /api/auth/me/change-password/
    Headers: Authorization: Token <token>
    Body: {
        "old_password": "string",
        "new_password": "string",
        "new_password_confirm": "string"
    }
    """
    serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        user = request.user
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        
        # Regenerate token after password change
        Token.objects.filter(user=user).delete()
        token = Token.objects.create(user=user)
        
        return Response({
            'message': 'Password changed successfully',
            'token': token.key
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_user(request, user_id=None):
    """
    Delete user account
    DELETE /api/auth/users/{user_id}/ (for admin)
    DELETE /api/auth/me/delete/ (for current user)
    Headers: Authorization: Token <token>
    """
    if user_id:
        # Delete specific user (admin functionality)
        user = get_object_or_404(User, id=user_id)
        # Add permission check here if needed
    else:
        # Delete current user
        user = request.user
    
    username = user.username
    user.delete()
    return Response({
        'message': f'User account "{username}" deleted successfully'
    }, status=status.HTTP_200_OK)

# User Profile APIs
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_profile(request):
    """
    Get current user's profile
    GET /api/auth/profile/
    Headers: Authorization: Token <token>
    """
    try:
        profile = request.user.profile
        serializer = UserProfileSerializer(profile)
        return Response({
            'profile': serializer.data
        }, status=status.HTTP_200_OK)
    except UserProfile.DoesNotExist:
        # Create profile if it doesn't exist
        profile = UserProfile.objects.create(user=request.user)
        serializer = UserProfileSerializer(profile)
        return Response({
            'profile': serializer.data
        }, status=status.HTTP_200_OK)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_user_profile(request):
    """
    Update current user's profile
    PUT /api/auth/profile/
    Headers: Authorization: Token <token>
    Body: {
        "bio": "string",
        "avatar": "string (URL)",
        "timezone": "string"
    }
    """
    try:
        profile = request.user.profile
    except UserProfile.DoesNotExist:
        profile = UserProfile.objects.create(user=request.user)
    
    serializer = UserProfileSerializer(profile, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response({
            'message': 'Profile updated successfully',
            'profile': serializer.data
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
