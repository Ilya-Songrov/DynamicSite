import django.contrib.auth
from django.db import transaction
from django.http import JsonResponse
from django.core import serializers
from django.shortcuts import render, redirect
from django.views import View
from django.contrib.auth.views import LoginView, LogoutView
from django.urls import reverse_lazy

from .serializers import CustomAccountSerializer, CustomUserLoginSerializer
from .models import CustomUser
from .forms import CustomUserCreationForm, CustomAuthenticationForm


class SignUpView(View):
    def get(self, request):
        form = CustomUserCreationForm()
        context = {'form': form}
        return render(request, 'accounts_ui/signup.html', context)

    def post(self, request):
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            secret_word = form.cleaned_data.get('secret_word')
            if secret_word != 'secret_word':
                form.add_error('secret_word', 'The secret word is incorrect.')
                return render(request, 'accounts_ui/signup.html', {'form': form})
            django.contrib.auth.login(request, user)  # Автоматично логінити користувача після реєстрації
            return redirect('/accounts/login/')
        return render(request, 'accounts_ui/signup.html', {'form': form})

class LogInView(LoginView):
    def get(self, request):
        form = CustomAuthenticationForm()
        context = {'form': form}
        return render(request, 'accounts_ui/login.html', context)

    def post(self, request):
        form = CustomAuthenticationForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            django.contrib.auth.login(request, user)
            return redirect('/core/dashboard/')
        return render(request, 'accounts_ui/login.html', {'form': form})


class LogOutView(LogoutView):
    next_page = reverse_lazy('/accounts/login/')  # Задайте URL для перенаправлення після виходу


