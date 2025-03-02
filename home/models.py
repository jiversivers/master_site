from django.db import models

class VisitorMetadata(models.Model):
    timestamp = models.DateTimeField(auto_now_add=True)
    ip_addr = models.GenericIPAddressField()
    referer = models.TextField()
    path = models.TextField()