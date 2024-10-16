from django.urls import path
from django.urls import re_path
from django.views.generic import RedirectView
from . import views


urlpatterns = [
    path('', RedirectView.as_view(url='company/<slug:company_slug>/', permanent=False)),
    path('company/<slug:company_slug>/', views.CompanyView.as_view(), name='company'),
    path('company/<slug:company_slug>/project/<uuid:project_id>/', views.ProjectView.as_view(), name='project'),
]