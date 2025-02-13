from django.contrib.auth import get_user_model
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from fraud.models import Transaction


User = get_user_model()# Replace User with your actual user model if it's custom

def health(request):
    try:
        from django.db import connection
        connection.cursor().execute("SELECT 1 FROM DUAL")
        return JsonResponse({'status': 'ok'}, status=200)
    except Exception as e:
        return JsonResponse({'status': 'error', "database_available": False, "msg": str(e)}, status=500)


@csrf_exempt
def total_users(request):
    total_users = len(User.objects.all())
    return JsonResponse({'status': 'success', 'total_users': total_users}, status=200)

@csrf_exempt
def demo_view(request):
    """
    Renders the HTML page for creating transactions.
    """
    return render(request, 'fraud/fraud-demo.html')



@csrf_exempt
def create_real_transaction(request):
    transaction = Transaction.create_real_transaction()

    return JsonResponse(
    {
            'status': 'success',
            'transactions': [
                transaction.json_response()
            ]
        },
        status=201
    )

@csrf_exempt
def create_fraudulent_transaction(request):
    FRAUD_TYPE_METHOD_MAP = {
        'too_far': Transaction.create_transaction_too_far,
        'too_many_count': Transaction.create_transaction_too_many_count,
        'too_many_amount': Transaction.create_transaction_too_many_amount,
        'too_large': Transaction.create_transaction_too_large,
    }
    fraud_type = request.POST.get('fraud_type')
    fraud_method = FRAUD_TYPE_METHOD_MAP.get(fraud_type)
    transactions = fraud_method()
    if not isinstance(transactions, list):
        transactions = [transactions]
    return JsonResponse(
        {
            'status': 'success',
            'transactions': [transaction.json_response() for transaction in transactions]
        },
        status=201
    )