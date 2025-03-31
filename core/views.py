from django.shortcuts import render
from django.contrib import messages
from django.views import View
from django.utils import translation
from django.shortcuts import redirect
from django.urls import reverse_lazy, reverse
from django.views.generic.edit import UpdateView, DeleteView
from django.http.response import HttpResponse, JsonResponse, HttpResponseRedirect
from django.shortcuts import get_object_or_404
from django.views.generic import ListView, DetailView
from .models import Company, Project, Client



class CompanyView(ListView):
    model = Company
    template_name = 'core_ui/company.html'
    context_object_name = 'company'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        company_slug = self.kwargs.get('company_slug')
        context['company'] = get_object_or_404(Company, slug=company_slug)
        return context
    

class ProjectView(DetailView):
    model = Project
    template_name = 'core_ui/project.html'
    context_object_name = 'project'

    def get_object(self):
        company_slug = self.kwargs.get('company_slug')
        project_id = self.kwargs.get('project_id')
        project = get_object_or_404(Project, id=project_id, company__slug=company_slug)
        return project

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        company_slug = self.kwargs.get('company_slug')
        project_id = self.kwargs.get('project_id')
        project = get_object_or_404(Project, id=project_id, company__slug=company_slug)
        context['project'] = project
        context['company'] = project.company
        return context


class CreateClientView(View):
    def post(self, request, company_slug, project_id):
        name = request.POST.get('name')
        phone = request.POST.get('phone')
        Client.objects.create(name=name, phone=phone)
        return HttpResponseRedirect('/some-url/')