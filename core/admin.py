from django.contrib import admin
from .models import Company, Project



@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'created_at', 'updated_at')
    prepopulated_fields = {'slug': ('name',)}
    readonly_fields = ('id', 'created_at', 'updated_at')

@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('company', 'title', 'description', 'created_at', 'updated_at')
    list_filter = ('company',)
    search_fields = ('title', 'description')
    readonly_fields = ('id', 'created_at', 'updated_at')