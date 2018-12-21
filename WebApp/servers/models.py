from django.db import models

class Server(models.Model):
    """System info to display"""
    computername = models.CharField(max_length=200)
    biosserial = models.CharField(max_length=200, null=True)
    manufacturer = models.CharField(max_length=200, null=True)
    model = models.CharField(max_length=200, null=True)
    osname = models.CharField(max_length=200, null=True)
    osversion = models.CharField(max_length=200, null=True)
    spversion = models.CharField(max_length=200, null=True)
    totalram = models.CharField(max_length=200, null=True)
    processors = models.CharField(max_length=100, null=True)
    lprocessors = models.CharField(max_length=200, null=True)

    def __str__(self):
        """Return a string representation of the model"""
        return self.computername
