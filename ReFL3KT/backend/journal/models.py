from django.db import models
from django.contrib.auth.models import User
from djrichtextfield.models import RichTextField

class Goal(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    
    def __str__(self):
        return self.name

class Task(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    goal = models.ForeignKey(Goal, on_delete=models.CASCADE, related_name='tasks')
    
    def __str__(self):
        return self.name

class JournalEntry(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    goal = models.ForeignKey(Goal, on_delete=models.CASCADE)
    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    entry_date = models.DateField()
    content = RichTextField()
    
    class Meta:
        # Define composite primary key
        unique_together = ('user', 'goal', 'task', 'entry_date')
        
    def __str__(self):
        return f"{self.user.username}'s entry for {self.task.name} on {self.entry_date}"
