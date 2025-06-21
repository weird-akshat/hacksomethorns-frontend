from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Goal, Task, JournalEntry
from .serializers import GoalSerializer, TaskSerializer, JournalEntrySerializer
from django.db.models import Q
from datetime import datetime

class GoalViewSet(viewsets.ModelViewSet):
    serializer_class = GoalSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Goal.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class TaskViewSet(viewsets.ModelViewSet):
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Task.objects.filter(goal__user=self.request.user)

class JournalEntryViewSet(viewsets.ModelViewSet):
    serializer_class = JournalEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return JournalEntry.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def by_date(self, request):
        """Get all journal entries for a specific date"""
        date_str = request.query_params.get('date', None)
        if not date_str:
            return Response({"error": "Date parameter is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            date_obj = datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD"}, status=status.HTTP_400_BAD_REQUEST)
        
        entries = JournalEntry.objects.filter(user=request.user, entry_date=date_obj)
        serializer = self.get_serializer(entries, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_task(self, request):
        """Get all journal entries for a specific task"""
        task_id = request.query_params.get('task_id', None)
        if not task_id:
            return Response({"error": "Task ID parameter is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        entries = JournalEntry.objects.filter(user=request.user, task_id=task_id).order_by('entry_date')
        serializer = self.get_serializer(entries, many=True)
        return Response(serializer.data)
