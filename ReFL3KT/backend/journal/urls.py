from rest_framework.routers import DefaultRouter
from .views import GoalViewSet, TaskViewSet, JournalEntryViewSet

router = DefaultRouter()
router.register(r'goals', GoalViewSet, basename='goal')
router.register(r'tasks', TaskViewSet, basename='task')       # Ensure this line exists
router.register(r'journal-entries', JournalEntryViewSet, basename='journal-entry')
urlpatterns = router.urls
