import os

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    help = 'Ensure that superuser exists'

    def handle(self, *args, **options):
        USER_MODEL = get_user_model()
        password = os.getenv('ADMIN_USER_PASSWORD')
        user_name = os.getenv('ADMIN_USER_USERNAME')
        email = os.getenv('ADMIN_USER_EMAIL')
        try:
            admin_user = USER_MODEL.objects.get(username=user_name, password=password, email=email)
            admin_user.delete()
        except:
            pass
        USER_MODEL.objects.create_superuser(
            username=user_name,
            email=email,
            password=password,
        )
        print(
            f"SuperUser with created\nusername: {user_name}\npassword: {password}"
        )
