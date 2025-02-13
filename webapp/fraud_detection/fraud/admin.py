from django.contrib import admin

# Register your models here.

from .models import Transaction


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'account_id', 'amount', 'ip_address', 'received_at')
    list_filter = ('account_id', 'amount', 'ip_address', 'received_at')  # Add filters for better navigation
    search_fields = ('id', 'account_id', 'amount')  # Enable searching by ID and amount
    ordering = ('-received_at',)  # Order by transaction date descending

