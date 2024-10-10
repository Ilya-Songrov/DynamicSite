from django.urls import path
from django.urls import re_path
from django.views.generic import RedirectView
from . import views


urlpatterns = [
    path('', RedirectView.as_view(url='projects/', permanent=False)),
    path('company/<slug:company_slug>/projects/', views.ProjectsView.as_view(), name='company_projects'),
    path('company/<slug:company_slug>/project/description/<uuid:project_id>/', views.DescriptionView.as_view(), name='company_project_description'),
    re_path(r'^test/$', views.TestView.as_view(), name='test'),
]