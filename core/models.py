from django.db import models
from django.utils.text import slugify
import uuid


class Company(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    slug = models.SlugField(unique=True, blank=True)
    name = models.CharField(max_length=255, unique=True, db_column='name')
    description = models.TextField(db_column='description')
    logo = models.ImageField(db_column='logo')
    background = models.ImageField(db_column='background')
    animation_video = models.ImageField(db_column='animation_video')
    animation_image = models.ImageField(db_column='animation_image')
    created_at = models.DateTimeField(auto_now_add=True, editable=False, db_column='created_at')
    updated_at = models.DateTimeField(auto_now=True, editable=False, db_column='updated_at')

    class Meta:
        ordering = ['-updated_at']
        verbose_name = "Company"
        verbose_name_plural = "Companies"
        db_table = "core_companies"
        constraints = [
            models.UniqueConstraint(
                fields=['slug'],
                name='core_companies_slug_unique',
            ),
        ]

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)


class Project(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='projects')
    title = models.CharField(max_length=255, unique=True, db_column='title')
    description = models.TextField(db_column='description')
    background = models.ImageField(db_column='background')
    created_at = models.DateTimeField(auto_now_add=True, editable=False, db_column='created_at')
    updated_at = models.DateTimeField(auto_now=True, editable=False, db_column='updated_at')

    class Meta:
        ordering = ['-updated_at']
        verbose_name = "Project"
        verbose_name_plural = "Projects"
        db_table = "core_projects"

    def __str__(self):
        return self.title
    


class Client(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.TextField(max_length=255, db_column='name')
    phone = models.TextField(max_length=255, db_column='phone')
    created_at = models.DateTimeField(auto_now_add=True, editable=False, db_column='created_at')
    updated_at = models.DateTimeField(auto_now=True, editable=False, db_column='updated_at')

    class Meta:
        ordering = ['-updated_at']
        verbose_name = "Client"
        verbose_name_plural = "Clients"
        db_table = "core_clients"

    def __str__(self):
        return self.name + " - " + self.phone
    