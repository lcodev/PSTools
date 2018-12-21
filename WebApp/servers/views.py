from django.shortcuts import render

from .models import Server

def index(request):
    """Home page"""
    return render(request, 'servers/index.html')

def details(request):
    """List server details"""
    servers = Server.objects.all()
    context = {'servers': servers}
    return render(request, 'servers/details.html', context)