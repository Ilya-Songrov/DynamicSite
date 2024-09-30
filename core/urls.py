from django.urls import path
from django.urls import re_path
from django.views.generic import RedirectView
from . import views


urlpatterns = [
    path('', RedirectView.as_view(url='dashboard/', permanent=False)),
    re_path(r'^dashboard/$', views.DashboardView.as_view(), name='dashboard'),
]