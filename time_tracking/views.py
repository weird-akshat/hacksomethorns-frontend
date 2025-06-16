from rest_framework import viewsets
from .models import TimeEntry, Category
from .serializers import TimeEntrySerializer, CategorySerializer

class TimeEntryViewSet(viewsets.ModelViewSet):
    serializer_class = TimeEntrySerializer
    def get_queryset(self):
        return TimeEntry.objects.filter(user=self.request.user)
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
