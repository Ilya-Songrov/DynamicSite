from django.urls import path
from django.urls import re_path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView, TokenBlacklistView
from .views import SignUpView, LogInView, LogOutView


urlpatterns = [
    re_path(r'^signup/$', SignUpView.as_view(), name='signup'),
    re_path(r'^signin/$', LogInView.as_view(), name='signin'),
    re_path(r'^login/$', LogInView.as_view(), name='login'),
    re_path(r'^logout/$', LogOutView.as_view(), name='logout'),
]