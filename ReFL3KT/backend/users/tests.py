from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from .models import UserProfile

User = get_user_model()

class UserModelTests(TestCase):
    def setUp(self):
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'first_name': 'Test',
            'last_name': 'User',
            'phone_number': '+1234567890'
        }

    def test_create_user(self):
        """Test creating a new user"""
        user = User.objects.create_user(**self.user_data)
        self.assertEqual(user.username, 'testuser')
        self.assertEqual(user.email, 'test@example.com')
        self.assertTrue(user.check_password('testpass123'))
        self.assertEqual(user.phone_number, '+1234567890')

    def test_create_user_profile(self):
        """Test creating a user profile"""
        user = User.objects.create_user(**self.user_data)
        profile = UserProfile.objects.create(user=user, bio='Test bio')
        self.assertEqual(profile.user, user)
        self.assertEqual(profile.bio, 'Test bio')

class UserAPITests(APITestCase):
    def setUp(self):
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123',
            'first_name': 'Test',
            'last_name': 'User',
            'phone_number': '+1234567890'
        }

    def test_user_registration(self):
        """Test user registration"""
        url = '/api/auth/register/'
        response = self.client.post(url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('token', response.data)
        self.assertIn('user', response.data)

    def test_user_registration_password_mismatch(self):
        """Test user registration with password mismatch"""
        url = '/api/auth/register/'
        data = self.user_data.copy()
        data['password_confirm'] = 'wrongpassword'
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_login(self):
        """Test user login"""
        # Create user first
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        
        # Login
        url = '/api/auth/login/'
        login_data = {
            'username': 'testuser',
            'password': 'testpass123'
        }
        response = self.client.post(url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)

    def test_user_login_invalid_credentials(self):
        """Test user login with invalid credentials"""
        url = '/api/auth/login/'
        login_data = {
            'username': 'nonexistent',
            'password': 'wrongpassword'
        }
        response = self.client.post(url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_get_current_user(self):
        """Test getting current authenticated user"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        token = Token.objects.create(user=user)
        
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        url = '/api/auth/me/'
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['username'], 'testuser')

    def test_get_all_users(self):
        """Test getting all users"""
        User.objects.create_user(username='user1', email='user1@example.com', password='pass123')
        User.objects.create_user(username='user2', email='user2@example.com', password='pass123')
        
        url = '/api/auth/users/'
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 2)

    def test_get_user_by_id(self):
        """Test getting user by ID"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        
        url = f'/api/auth/users/{user.id}/'
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['username'], 'testuser')

    def test_update_user(self):
        """Test updating user information"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        token = Token.objects.create(user=user)
        
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        url = '/api/auth/me/update/'
        update_data = {
            'first_name': 'Updated',
            'last_name': 'Name'
        }
        response = self.client.put(url, update_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['user']['first_name'], 'Updated')

    def test_logout_user(self):
        """Test user logout"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
        token = Token.objects.create(user=user)
        
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        url = '/api/auth/logout/'
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify token is deleted
        self.assertFalse(Token.objects.filter(key=token.key).exists())

    def test_change_password(self):
        """Test changing user password"""
        user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='oldpass123'
        )
        token = Token.objects.create(user=user)
        
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        url = '/api/auth/me/change-password/'
        password_data = {
            'old_password': 'oldpass123',
            'new_password': 'newpass123',
            'new_password_confirm': 'newpass123'
        }
        response = self.client.post(url, password_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify password changed
        user.refresh_from_db()
        self.assertTrue(user.check_password('newpass123'))
