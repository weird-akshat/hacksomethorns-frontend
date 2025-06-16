from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Sum, Q
from datetime import timedelta
from .models import Category, TimeEntry
from .serializers import CategorySerializer, TimeEntrySerializer

class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Category.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class TimeEntryViewSet(viewsets.ModelViewSet):
    serializer_class = TimeEntrySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return TimeEntry.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Deactivate any existing active entries
        TimeEntry.objects.filter(user=self.request.user, is_active=True).update(is_active=False)
        serializer.save(user=self.request.user, is_active=True)

    @action(detail=False, methods=['get'])
    def current_time_entry(self, request):
        try:
            entry = TimeEntry.objects.get(user=request.user, is_active=True)
            serializer = self.get_serializer(entry)
            return Response(serializer.data)
        except TimeEntry.DoesNotExist:
            return Response(None)

    @action(detail=False, methods=['get'])
    def recent_entries(self, request):
        # Get entries from last 7 days
        start_date = timezone.now() - timedelta(days=7)
        entries = TimeEntry.objects.filter(
            user=request.user,
            start_time__gte=start_date
        ).order_by('-start_time')

        # Group entries by date
        entries_by_date = {}
        for entry in entries:
            date_str = entry.start_time.date().isoformat()
            if date_str not in entries_by_date:
                entries_by_date[date_str] = []
            entries_by_date[date_str].append(self.get_serializer(entry).data)

        return Response(entries_by_date)

    @action(detail=False, methods=['get'])
    def analytics(self, request):
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        category_id = request.query_params.get('category_id')

        if not start_date or not end_date:
            return Response(
                {"error": "start_date and end_date are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            start_date = timezone.datetime.strptime(start_date, '%Y-%m-%d')
            end_date = timezone.datetime.strptime(end_date, '%Y-%m-%d')
        except ValueError:
            return Response(
                {"error": "Invalid date format. Use YYYY-MM-DD"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Base query
        query = Q(
            user=request.user,
            start_time__gte=start_date,
            start_time__lte=end_date
        )

        if category_id:
            query &= Q(category_id=category_id)

        entries = TimeEntry.objects.filter(query)

        # Calculate total duration for each category
        category_stats = {}
        for entry in entries:
            category_name = entry.category.name if entry.category else "Uncategorized"
            if category_name not in category_stats:
                category_stats[category_name] = timedelta()
            category_stats[category_name] += entry.duration

        # Calculate daily stats
        daily_stats = {}
        for entry in entries:
            date_str = entry.start_time.date().isoformat()
            if date_str not in daily_stats:
                daily_stats[date_str] = {}
            
            category_name = entry.category.name if entry.category else "Uncategorized"
            if category_name not in daily_stats[date_str]:
                daily_stats[date_str][category_name] = timedelta()
            daily_stats[date_str][category_name] += entry.duration

        return Response({
            'category_totals': {k: str(v) for k, v in category_stats.items()},
            'daily_stats': daily_stats
        })
