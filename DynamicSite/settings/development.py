
from .base import *

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['*', '127.0.0.1', '176.36.224.228']

# Database
# https://docs.djangoproject.com/en/4.2/ref/settings/#databases
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'dynamic_site_db_test',
        'USER': 'dynamic_site_user_test',
        'PASSWORD': '123456',
        "HOST": "127.0.0.1",
        "PORT": "5432",
    }
}

