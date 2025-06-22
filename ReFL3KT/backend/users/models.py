from django.contrib.auth.models import User
from django.db import models
from .authentication.validators import validate_phone_number

class UserProfile(models.Model):
    """
    Extended user profile with additional fields
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone_number = models.CharField(
        max_length=15, 
        blank=True, 
        null=True,
        validators=[validate_phone_number],
        help_text="Phone number in international format (e.g., +1234567890)"
    )
    bio = models.TextField(blank=True, null=True)
    avatar = models.URLField(blank=True, null=True)
    timezone = models.CharField(max_length=50, default='UTC')
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"
    
    class Meta:
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"
