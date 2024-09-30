from django.shortcuts import render
from django.contrib import messages
from django.views import View
from django.utils import translation
from django.shortcuts import redirect
from django.urls import reverse_lazy, reverse
from django.views.generic.edit import UpdateView, DeleteView
from django.http.response import HttpResponse, JsonResponse


class DashboardView(View):
    def get(self, request):
        context = {
        }
        return render(request, 'core_ui/index.html', context)

