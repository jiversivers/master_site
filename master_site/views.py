from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render

# Create your views here.
def home(request):
    installed_apps = settings.INSTALLED_APPS
    return render(request,
                  'master_site/home.html',
                  {'installed_apps': installed_apps})