from django.urls import path
from django.urls import re_path
from django.views.generic import RedirectView
from . import views


urlpatterns = [
    path('', RedirectView.as_view(url='company/svitlo-church/', permanent=False)),
    path('company/<slug:company_slug>/', views.CompanyView.as_view(), name='company'),
    path('company/<slug:company_slug>/project/<uuid:project_id>/', views.ProjectView.as_view(), name='project'),
    path('company/<slug:company_slug>/project/<uuid:project_id>/create_client/', views.CreateClientView.as_view(), name='create_client'),
]