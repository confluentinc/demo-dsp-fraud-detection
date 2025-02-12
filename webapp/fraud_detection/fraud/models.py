import random

from django.contrib.auth import get_user_model
from django.db import models

from faker import Faker

ALLOWED_IPS = [
    "8.8.8.8",
    "8.8.4.4",
    "34.192.0.0",
    "34.201.0.0",
    "35.160.0.0",
    "35.167.0.0",
    "52.0.0.0",
    "52.25.0.0",
    "64.233.160.0",
    "66.102.0.0",
    "104.16.0.0",
    "172.217.0.0",
    "13.52.0.0",
    "13.57.0.0",
    "23.0.0.0",
    "199.36.153.8",
    "45.56.0.1",
    "192.0.2.0",
    "198.51.100.0",
    "203.0.113.0"
]

BLOCKED_IPS = [
    # European IP Addresses
    "1.1.1.1",  # Cloudflare DNS (Europe-focused routing)
    "1.0.0.1",  # Cloudflare alternate DNS
    "62.210.16.6",  # OVH (France)
    "145.239.32.25",  # OVHCloud (France)
    "195.2.240.4",  # OpenNIC DNS (Germany)
    "80.80.80.80",  # Freenom World DNS (Netherlands)
    "81.169.160.101",  # Strato AG (Germany)
    "91.121.0.0",  # Gandi.net (France)

    # Asian IP Addresses
    "114.114.114.114",  # 114 DNS (China-based)
    "223.5.5.5",  # AliDNS (China)
    "1.12.12.12",  # Alternate Chinese DNS
    "202.54.1.1",  # Indian ISP DNS Server
    "110.44.116.100",  # ISP in Bangladesh
    "116.203.0.1",  # Hetzner Server Asia Connectivity
    "103.224.182.207",  # Afghanistan-based infrastructure

    # Oceania IP Addresses
    "203.2.75.123",  # Australian-based DNS
    "203.97.78.43",  # Spark NZ ISP (New Zealand)

    # African IP Addresses
    "165.227.56.83",  # DigitalOcean South African node
    "102.130.121.2",  # Rain ISP (South Africa)
    "41.79.129.2",  # Nigerian-based ISP

    # South American IP Addresses
    "186.202.6.44",  # Brazil-based DNS
    "200.40.30.245",  # Uruguay ISP
]

MAX_NORMAL_TRANSACTION_AMOUNT = 50
MAX_TRANSACTION_FLAG_AMOUNT = 1000
BURST_TRANSACTION_FLAG_COUNT = 11




# Create your models here.
class Transaction(models.Model):
    """
    Represents a transaction that affects one or more accounts.
    """
    account = models.ForeignKey(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='user_transactions',
        null=True,
        blank=True  # Blank for deposits
    )
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    received_at = models.DateTimeField(auto_now_add=True)  # Automatically logs transaction time
    ip_address = models.GenericIPAddressField(protocol='both', unpack_ipv4=True)

    class Meta:
        db_table = 'user_transaction'

    def __str__(self):
        return f"{self.transaction_type.title()} - {self.amount} @ {self.timestamp}"



    USERS = None

    @property
    def username(self):
        return self.account.username

    @classmethod
    def get_users(cls):
        if cls.USERS is None:
            cls.USERS = list(get_user_model().objects.all())
        return cls.USERS

    @classmethod
    def load_users(cls):
        User = get_user_model()
        fake = Faker()
        users_to_create = list()
        usernames_seen = set(User.objects.values_list('username', flat=True))
        while len(users_to_create) < 1000:
            username = fake.user_name()
            email = fake.email()
            password = "password123"
            if username not in usernames_seen:
                usernames_seen.add(username)
                users_to_create.append(
                    User(
                        username=username,
                        email=email,
                        password=password
                    )
                )
        User.objects.bulk_create(users_to_create)
        return len(users_to_create)

    @classmethod
    def get_normal_amount(cls):
        return random.uniform(0.25, MAX_NORMAL_TRANSACTION_AMOUNT)

    @classmethod
    def create_real_transaction(cls):
        user = random.choice(cls.get_users())
        amount = cls.get_normal_amount()
        ip_address = random.choice(ALLOWED_IPS)
        transaction = Transaction.objects.create(
            account=user,
            amount=amount,
            ip_address=ip_address,
        )
        return transaction

    @classmethod
    def create_transaction_too_large(cls):
        user = random.choice(cls.get_users())
        amount = random.uniform(MAX_TRANSACTION_FLAG_AMOUNT, MAX_TRANSACTION_FLAG_AMOUNT+cls.get_normal_amount())
        ip_address = random.choice(ALLOWED_IPS)
        transaction = Transaction.objects.create(
            account=user,
            amount=amount,
            ip_address=ip_address,
        )
        return transaction

    @classmethod
    def create_transaction_too_many_count(cls):
        transactions = list()
        ip_address = random.choice(ALLOWED_IPS)
        user = random.choice(cls.get_users())
        for _ in range(BURST_TRANSACTION_FLAG_COUNT):
            amount = cls.get_normal_amount()
            transactions.append(
                Transaction(
                    account=user,
                    amount=amount,
                    ip_address=ip_address,
                )
            )
        for transaction in transactions:
            transaction.save()
        return transactions

    @classmethod
    def create_transaction_too_many_amount(cls):
        total_transaction_cost = 0
        transactions = list()
        ip_address = random.choice(ALLOWED_IPS)
        user = random.choice(cls.get_users())
        while total_transaction_cost < MAX_TRANSACTION_FLAG_AMOUNT:
            amount = random.uniform(MAX_NORMAL_TRANSACTION_AMOUNT, MAX_TRANSACTION_FLAG_AMOUNT)
            transactions.append(
                Transaction(
                    account=user,
                    amount=amount,
                    ip_address=ip_address,
                )
            )
            total_transaction_cost += amount
        for transaction in transactions:
            transaction.save()
        return transactions


    @classmethod
    def create_transaction_too_far(cls):
        user = random.choice(cls.get_users())
        amount = cls.get_normal_amount()
        ip_address = random.choice(BLOCKED_IPS)
        transaction = Transaction.objects.create(
            account=user,
            amount=amount,
            ip_address=ip_address,
        )
        return transaction

    def json_response(self):
        return {
            "transaction_id": self.id,
            "account_id": self.username,
            "amount": self.amount,
            "ip_address": self.ip_address,
            "received_at": self.received_at
        }



