from django.urls import path
from . import views

urlpatterns = [
    # Authentication endpoints
    path('register/', views.register_user, name='api_register'),
    path('login/', views.login_user, name='api_login'),
    path('logout/', views.logout_user, name='api_logout'),
    
    # User management endpoints
    path('users/', views.get_all_users, name='api_get_all_users'),
    path('users/create/', views.create_user, name='api_create_user'),
    path('users/<int:user_id>/', views.get_user_by_id, name='api_get_user_by_id'),
    path('users/<int:user_id>/update/', views.update_user, name='api_update_user_by_id'),
    path('users/<int:user_id>/delete/', views.delete_user, name='api_delete_user_by_id'),
    
    # Current user endpoints
    path('me/', views.get_current_user, name='api_get_current_user'),
    path('me/update/', views.update_user, name='api_update_current_user'),
    path('me/change-password/', views.change_password, name='api_change_password'),
    path('me/delete/', views.delete_user, name='api_delete_current_user'),
    
    # User profile endpoints
    path('profile/', views.get_user_profile, name='api_get_user_profile'),
    path('profile/update/', views.update_user_profile, name='api_update_user_profile'),
]
