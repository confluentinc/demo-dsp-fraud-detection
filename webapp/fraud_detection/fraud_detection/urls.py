"""
URL configuration for fraud_detection project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

from fraud.views import demo_view, create_real_transaction, create_fraudulent_transaction, health, \
    total_users

urlpatterns = [
    # admin UI view
    path('admin/', admin.site.urls),
    # health check for Kubernetes
    path('health/', health, name="health"),
    # fraud demo UI view
    path('fraud-demo/', demo_view, name='fraud-demo'),
    # fraud demo API's
    path('create-real-transaction/', create_real_transaction, name='create-real-transaction'),
    path('create-fraudulant-transaction/', create_fraudulent_transaction, name='create-fraudulent-transaction'),
    path('total_users/', total_users, name='total_users'),
]
