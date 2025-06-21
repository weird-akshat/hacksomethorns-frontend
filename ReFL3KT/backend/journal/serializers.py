from rest_framework import serializers
from .models import Goal, Task, JournalEntry
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username']

class GoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Goal
        fields = ['id', 'name']

class TaskSerializer(serializers.ModelSerializer):
    goal_name = serializers.CharField(source='goal.name', read_only=True)
    class Meta:
        model = Task
        fields = [
            'user',
            'id',
            'name',
            'goal',
            'goal_name',
        ]
        read_only_fields = ['goal_name']

class JournalEntrySerializer(serializers.ModelSerializer):
    goal_name = serializers.CharField(source='goal.name', read_only=True)
    task_name = serializers.CharField(source='task.name', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = JournalEntry
        fields = ['user', 'goal', 'task', 'entry_date', 'content', 'goal_name', 'task_name', 'username']
