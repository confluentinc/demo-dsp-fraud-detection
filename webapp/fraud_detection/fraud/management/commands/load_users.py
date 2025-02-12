from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from faker import Faker

from fraud.models import Transaction


class Command(BaseCommand):
    help = 'Loads users randomly'

    def handle(self, *args, **options):
        users = get_user_model().objects.all().delete()
        users_created = Transaction.load_users()
        print(
            f"Created {users_created} users."
        )