from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.utils import timezone
from django.db.models import Sum, Q, F, DurationField
from datetime import timedelta
from django.shortcuts import get_object_or_404
from collections import defaultdict
from .models import Category, TimeEntry
from .serializers import CategorySerializer, TimeEntrySerializer

class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return Category.objects.all().order_by('name')

    def perform_create(self, serializer):
        serializer.save()

    def perform_update(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        # Check if category is in use
        if TimeEntry.objects.filter(category=instance).exists():
            return Response(
                {"error": "Cannot delete category that has time entries"},
                status=status.HTTP_400_BAD_REQUEST
            )
        instance.delete()

    @action(detail=True, methods=['get'])
    def analytics(self, request, pk=None):
        category = self.get_object()
        start_date = request.query_params.get('_startTime')
        end_date = request.query_params.get('_endTime')

        if not start_date or not end_date:
            return Response(
                {"error": "_startTime and _endTime are required"},
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

        # Get all entries for this category
        entries = TimeEntry.objects.filter(
            category=category,
            start_time__gte=start_date,
            start_time__lte=end_date
        ).order_by('start_time')

        # Group entries by description
        grouped_entries = defaultdict(timedelta)
        for entry in entries:
            grouped_entries[entry.description] += entry.duration

        # Calculate daily stats
        daily_stats = defaultdict(timedelta)
        for entry in entries:
            date_str = entry.start_time.date().isoformat()
            daily_stats[date_str] += entry.duration

        # Calculate total duration
        total_duration = sum(grouped_entries.values(), timedelta())

        # Format the response
        response_data = {
            'category': {
                '_categoryId': category.id,
                '_name': category.name,
                '_color': category.color
            },
            'total_duration': str(total_duration),
            'daily_stats': {
                date: str(duration) for date, duration in daily_stats.items()
            },
            'grouped_entries': [
                {
                    '_description': description,
                    '_duration': str(duration)
                }
                for description, duration in grouped_entries.items()
            ],
            'time_entries': TimeEntrySerializer(entries, many=True).data
        }

        return Response(response_data)

class TimeEntryViewSet(viewsets.ModelViewSet):
    serializer_class = TimeEntrySerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        queryset = TimeEntry.objects.all()
        
        # Add filtering options
        category_id = self.request.query_params.get('_categoryId')
        start_date = self.request.query_params.get('_startTime')
        end_date = self.request.query_params.get('_endTime')
        
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        
        if start_date:
            try:
                start_date = timezone.datetime.strptime(start_date, '%Y-%m-%d')
                queryset = queryset.filter(start_time__gte=start_date)
            except ValueError:
                pass
        
        if end_date:
            try:
                end_date = timezone.datetime.strptime(end_date, '%Y-%m-%d')
                queryset = queryset.filter(start_time__lte=end_date)
            except ValueError:
                pass
        
        return queryset.order_by('-start_time')

    def perform_create(self, serializer):
        # Deactivate any existing active entries
        TimeEntry.objects.filter(is_active=True).update(is_active=False)
        serializer.save(is_active=True)

    def perform_update(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        instance.delete()

    @action(detail=False, methods=['get'])
    def current_time_entry(self, request):
        try:
            entry = TimeEntry.objects.get(is_active=True)
            serializer = self.get_serializer(entry)
            return Response(serializer.data)
        except TimeEntry.DoesNotExist:
            return Response(None)

    @action(detail=False, methods=['get'])
    def recent_entries(self, request):
        # Get entries from last 7 days
        start_date = timezone.now() - timedelta(days=7)
        entries = TimeEntry.objects.filter(
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
        start_date = request.query_params.get('_startTime')
        end_date = request.query_params.get('_endTime')
        category_id = request.query_params.get('_categoryId')

        if not start_date or not end_date:
            return Response(
                {"error": "_startTime and _endTime are required"},
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
            start_time__gte=start_date,
            start_time__lte=end_date
        )

        if category_id:
            query &= Q(category_id=category_id)

        entries = TimeEntry.objects.filter(query)

        # Group entries by description and category
        grouped_entries = defaultdict(lambda: defaultdict(timedelta))
        category_stats = defaultdict(timedelta)
        daily_stats = defaultdict(lambda: defaultdict(timedelta))
        
        for entry in entries:
            category_name = entry.category.name if entry.category else "Uncategorized"
            description = entry.description or "No description"
            date_str = entry.start_time.date().isoformat()
            
            # Group by description and category
            grouped_entries[category_name][description] += entry.duration
            
            # Update category totals
            category_stats[category_name] += entry.duration
            
            # Update daily stats
            daily_stats[date_str][category_name] += entry.duration

        # Calculate total duration
        total_duration = sum(category_stats.values(), timedelta())

        # Format the response
        response_data = {
            'total_duration': str(total_duration),
            'category_totals': {
                category: str(duration)
                for category, duration in category_stats.items()
            },
            'daily_stats': {
                date: {
                    category: str(duration)
                    for category, duration in categories.items()
                }
                for date, categories in daily_stats.items()
            },
            'grouped_entries': {
                category: [
                    {
                        '_description': description,
                        '_duration': str(duration)
                    }
                    for description, duration in descriptions.items()
                ]
                for category, descriptions in grouped_entries.items()
            }
        }

        return Response(response_data)
