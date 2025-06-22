from django.core.exceptions import ValidationError
import re

def validate_phone_number(phone_number):
    """
    Validate phone number format
    """
    if not phone_number:
        return True  # Allow empty phone numbers
    
    # Basic phone number validation (adjust pattern as needed)
    pattern = r'^\+?1?\d{9,15}$'
    if not re.match(pattern, phone_number):
        raise ValidationError('Invalid phone number format. Use format: +1234567890')
    return True

def validate_username(username):
    """
    Custom username validation
    """
    if len(username) < 3:
        raise ValidationError('Username must be at least 3 characters long.')
    
    if not re.match(r'^[a-zA-Z0-9_]+$', username):
        raise ValidationError('Username can only contain letters, numbers, and underscores.')
    
    return True
