# User Authentication API Documentation

This API provides comprehensive user authentication and management functionality using Django's default User model extended with additional fields.

## User Model Structure

The User model includes the following fields:
- `id`: Auto-generated primary key
- `username`: Unique username (required)
- `email`: Email address
- `first_name`: User's first name
- `last_name`: User's last name
- `phone_number`: Phone number with validation
- `password`: Encrypted password
- `date_joined`: Auto-generated timestamp
- `is_verified`: Boolean field for email verification
- `is_active`: Boolean field for account status

## Authentication

All authenticated endpoints require a token in the header:
```
Authorization: Token <your-token-here>
```

## API Endpoints

### Authentication Endpoints

#### 1. Register User
- **URL**: `POST /api/auth/register/`
- **Permission**: AllowAny
- **Description**: Register a new user account
- **Request Body**:
```json
{
    "username": "johndoe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone_number": "+1234567890",
    "password": "securepassword123",
    "password_confirm": "securepassword123"
}
```
- **Response**:
```json
{
    "message": "User registered successfully",
    "user": {
        "id": 1,
        "username": "johndoe",
        "email": "john@example.com",
        "first_name": "John",
        "last_name": "Doe",
        "phone_number": "+1234567890",
        "date_joined": "2025-06-20T10:30:00Z",
        "is_verified": false,
        "profile": {
            "bio": null,
            "avatar": null,
            "timezone": "UTC",
            "created_at": "2025-06-20T10:30:00Z",
            "updated_at": "2025-06-20T10:30:00Z"
        }
    },
    "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
}
```

#### 2. Login User
- **URL**: `POST /api/auth/login/`
- **Permission**: AllowAny
- **Description**: Login and get authentication token
- **Request Body**:
```json
{
    "username": "johndoe",
    "password": "securepassword123"
}
```
- **Response**:
```json
{
    "message": "Login successful",
    "user": {
        "id": 1,
        "username": "johndoe",
        "email": "john@example.com",
        "first_name": "John",
        "last_name": "Doe",
        "phone_number": "+1234567890",
        "date_joined": "2025-06-20T10:30:00Z",
        "is_verified": false,
        "profile": {...}
    },
    "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
}
```

#### 3. Logout User
- **URL**: `POST /api/auth/logout/`
- **Permission**: IsAuthenticated
- **Description**: Logout and invalidate token
- **Headers**: `Authorization: Token <token>`
- **Response**:
```json
{
    "message": "Logout successful"
}
```

### User Management Endpoints

#### 4. Get All Users
- **URL**: `GET /api/auth/users/`
- **Permission**: AllowAny (consider changing to IsAuthenticated)
- **Description**: Get list of all users
- **Query Parameters**:
  - `search`: Search by username, first_name, last_name, email
  - `limit`: Limit number of results
- **Response**:
```json
{
    "users": [
        {
            "id": 1,
            "username": "johndoe",
            "email": "john@example.com",
            "first_name": "John",
            "last_name": "Doe",
            "phone_number": "+1234567890",
            "date_joined": "2025-06-20T10:30:00Z",
            "is_verified": false,
            "profile": {...}
        }
    ],
    "count": 1
}
```

#### 5. Get User by ID
- **URL**: `GET /api/auth/users/{user_id}/`
- **Permission**: AllowAny
- **Description**: Get specific user by ID
- **Response**:
```json
{
    "user": {
        "id": 1,
        "username": "johndoe",
        "email": "john@example.com",
        "first_name": "John",
        "last_name": "Doe",
        "phone_number": "+1234567890",
        "date_joined": "2025-06-20T10:30:00Z",
        "is_verified": false,
        "profile": {...}
    }
}
```

#### 6. Create User
- **URL**: `POST /api/auth/users/create/`
- **Permission**: AllowAny (consider changing based on requirements)
- **Description**: Create a new user (simplified version)
- **Request Body**:
```json
{
    "username": "janedoe",
    "email": "jane@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "phone_number": "+1234567891",
    "password": "securepassword123"
}
```

#### 7. Get Current User
- **URL**: `GET /api/auth/me/`
- **Permission**: IsAuthenticated
- **Description**: Get current authenticated user's data
- **Headers**: `Authorization: Token <token>`
- **Response**:
```json
{
    "user": {
        "id": 1,
        "username": "johndoe",
        "email": "john@example.com",
        "first_name": "John",
        "last_name": "Doe",
        "phone_number": "+1234567890",
        "date_joined": "2025-06-20T10:30:00Z",
        "is_verified": false,
        "profile": {...}
    }
}
```

#### 8. Update User
- **URL**: `PUT /api/auth/me/update/` (current user)
- **URL**: `PUT /api/auth/users/{user_id}/update/` (specific user)
- **Permission**: IsAuthenticated
- **Description**: Update user information
- **Headers**: `Authorization: Token <token>`
- **Request Body**:
```json
{
    "first_name": "Johnny",
    "last_name": "Doe",
    "email": "johnny@example.com",
    "phone_number": "+1234567892"
}
```

#### 9. Change Password
- **URL**: `POST /api/auth/me/change-password/`
- **Permission**: IsAuthenticated
- **Description**: Change user password
- **Headers**: `Authorization: Token <token>`
- **Request Body**:
```json
{
    "old_password": "oldpassword123",
    "new_password": "newpassword123",
    "new_password_confirm": "newpassword123"
}
```
- **Response**:
```json
{
    "message": "Password changed successfully",
    "token": "new9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
}
```

#### 10. Delete User
- **URL**: `DELETE /api/auth/me/delete/` (current user)
- **URL**: `DELETE /api/auth/users/{user_id}/delete/` (specific user)
- **Permission**: IsAuthenticated
- **Description**: Delete user account
- **Headers**: `Authorization: Token <token>`
- **Response**:
```json
{
    "message": "User account \"johndoe\" deleted successfully"
}
```

### User Profile Endpoints

#### 11. Get User Profile
- **URL**: `GET /api/auth/profile/`
- **Permission**: IsAuthenticated
- **Description**: Get current user's profile
- **Headers**: `Authorization: Token <token>`
- **Response**:
```json
{
    "profile": {
        "user_id": 1,
        "username": "johndoe",
        "bio": "Software developer passionate about Django",
        "avatar": "https://example.com/avatar.jpg",
        "timezone": "America/New_York",
        "created_at": "2025-06-20T10:30:00Z",
        "updated_at": "2025-06-20T10:30:00Z"
    }
}
```

#### 12. Update User Profile
- **URL**: `PUT /api/auth/profile/update/`
- **Permission**: IsAuthenticated
- **Description**: Update current user's profile
- **Headers**: `Authorization: Token <token>`
- **Request Body**:
```json
{
    "bio": "Senior software developer with 5+ years experience",
    "avatar": "https://example.com/new-avatar.jpg",
    "timezone": "America/Los_Angeles"
}
```

## Error Responses

All endpoints return appropriate HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (missing or invalid token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found
- `500`: Internal Server Error

Example error response:
```json
{
    "error": "Invalid credentials"
}
```

Or validation errors:
```json
{
    "username": ["This field is required."],
    "password": ["This password is too short. It must contain at least 8 characters."]
}
```

## Testing the API

You can test the API using curl, Postman, or any HTTP client:

```bash
# Register a new user
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","first_name":"Test","last_name":"User","phone_number":"+1234567890","password":"testpass123","password_confirm":"testpass123"}'

# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass123"}'

# Get current user (replace <token> with actual token)
curl -X GET http://localhost:8000/api/auth/me/ \
  -H "Authorization: Token <token>"
```

## Security Notes

1. **Phone Number Validation**: The API includes phone number validation using regex patterns
2. **Password Validation**: Uses Django's built-in password validators
3. **Token Authentication**: Uses Django REST framework's token authentication
4. **CORS**: Make sure CORS is properly configured for frontend access
5. **Permissions**: Consider updating AllowAny permissions to IsAuthenticated for production use
