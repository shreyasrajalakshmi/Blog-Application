from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    title = models.CharField(max_length=200)
    summary = models.CharField(max_length=255, blank=True)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.summary:
            self.summary = self.content[:100]
        super().save(*args, **kwargs)

    def __str__(self):
        return self.title
