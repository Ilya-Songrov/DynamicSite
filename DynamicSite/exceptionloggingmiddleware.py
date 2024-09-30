from django.shortcuts import render
from django.contrib.auth.mixins import LoginRequiredMixin
from django.http import JsonResponse
from django.forms.models import model_to_dict
from django.db import transaction
from django.db.models import Count, Sum, Subquery, Exists, OuterRef, DateTimeField, QuerySet
from django.db.utils import IntegrityError
from django.core.serializers import serialize
from django.shortcuts import get_object_or_404
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.generics import GenericAPIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from datetime import datetime
import json


class ExceptionLoggingMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        return self.get_response(request)

        # Code to be executed for each request before
        # the view (and later middleware) are called.
        try:
            print(f"\n")
            print(f"RQ_BODY: {request.body.decode()}")
            # print(f"RQ_HEADERS: {request.headers}")
            # print(f"RQ_SCHEME: {request.scheme}")
            # print(f"RQ_METHOD: {request.method}")
            # print(f"RQ_META: {request.META}")
        except:
            print("Something else went wrong with the print request")
        response = self.get_response(request)
        try:
            print(f"RS_BODY: {response.content.decode()}")
        except:
            print("Something else went wrong with the print response")
        return response