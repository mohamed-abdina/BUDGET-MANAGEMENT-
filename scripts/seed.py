"""
Seed script for Budget Management application.
Run: python scripts/seed.py
"""
import os
import sys
import django

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'budget_management.settings')

django.setup()

from django.contrib.auth import get_user_model
from income.models import IncomeCategory, Income
from expenses.models import ExpenseCategory, Expense
from budgets.models import Budget
from datetime import date, timedelta
from decimal import Decimal

User = get_user_model()

def seed():
    # Create demo user
    user, created = User.objects.get_or_create(
        email='demo@example.com',
        defaults={
            'username': 'demo@example.com',
            'first_name': 'Demo User',
            'is_staff': False,
            'is_active': True,
        }
    )
    if created:
        user.set_password('password123')
        user.save()
        print(f'Created user: {user.email}')
    else:
        print(f'User already exists: {user.email}')

    # Income categories
    income_categories_data = [
        {'name': 'Salary', 'color': '#1D8763', 'icon': 'ti-cash'},
        {'name': 'Business', 'color': '#3B6FB0', 'icon': 'ti-building-store'},
        {'name': 'Freelance', 'color': '#B8862F', 'icon': 'ti-laptop'},
        {'name': 'Investments', 'color': '#7B61FF', 'icon': 'ti-chart-line'},
    ]

    income_cats = {}
    for cat_data in income_categories_data:
        cat, _ = IncomeCategory.objects.get_or_create(
            user=user,
            name=cat_data['name'],
            defaults=cat_data
        )
        income_cats[cat_data['name']] = cat
    print('Income categories created.')

    # Expense categories
    expense_categories_data = [
        {'name': 'Food', 'color': '#C2483F', 'icon': 'ti-brand-shopee'},
        {'name': 'Transport', 'color': '#E67E22', 'icon': 'ti-car'},
        {'name': 'Utilities', 'color': '#3B6FB0', 'icon': 'ti-bolt'},
        {'name': 'Entertainment', 'color': '#9B59B6', 'icon': 'ti-movie'},
        {'name': 'Savings', 'color': '#1D8763', 'icon': 'ti-piggy-bank'},
        {'name': 'Other', 'color': '#5B6272', 'icon': 'ti-dots'},
    ]

    expense_cats = {}
    for cat_data in expense_categories_data:
        cat, _ = ExpenseCategory.objects.get_or_create(
            user=user,
            name=cat_data['name'],
            defaults=cat_data
        )
        expense_cats[cat_data['name']] = cat
    print('Expense categories created.')

    # Sample income
    today = date.today()
    incomes = [
        {'category': income_cats['Salary'], 'amount': Decimal('85000'), 'description': 'Monthly salary', 'date': today.replace(day=1)},
        {'category': income_cats['Freelance'], 'amount': Decimal('15000'), 'description': 'Web design project', 'date': today.replace(day=5)},
        {'category': income_cats['Business'], 'amount': Decimal('25000'), 'description': 'Consulting fees', 'date': today.replace(day=10)},
    ]

    for inc_data in incomes:
        Income.objects.get_or_create(
            user=user,
            description=inc_data['description'],
            date=inc_data['date'],
            defaults=inc_data
        )
    print('Sample income created.')

    # Sample expenses
    expenses = [
        {'category': expense_cats['Food'], 'amount': Decimal('12000'), 'description': 'Groceries', 'date': today.replace(day=2)},
        {'category': expense_cats['Food'], 'amount': Decimal('3500'), 'description': 'Restaurant dinner', 'date': today.replace(day=7)},
        {'category': expense_cats['Transport'], 'amount': Decimal('4500'), 'description': 'Fuel', 'date': today.replace(day=3)},
        {'category': expense_cats['Utilities'], 'amount': Decimal('2800'), 'description': 'Electricity bill', 'date': today.replace(day=4)},
        {'category': expense_cats['Utilities'], 'amount': Decimal('1500'), 'description': 'Internet', 'date': today.replace(day=4)},
        {'category': expense_cats['Entertainment'], 'amount': Decimal('2000'), 'description': 'Movie tickets', 'date': today.replace(day=8)},
        {'category': expense_cats['Other'], 'amount': Decimal('5000'), 'description': 'Shopping', 'date': today.replace(day=6)},
    ]

    for exp_data in expenses:
        Expense.objects.get_or_create(
            user=user,
            description=exp_data['description'],
            date=exp_data['date'],
            defaults=exp_data
        )
    print('Sample expenses created.')

    # Sample budgets
    budgets = [
        {'category': expense_cats['Food'], 'amount': Decimal('18000'), 'month': today.month, 'year': today.year},
        {'category': expense_cats['Transport'], 'amount': Decimal('6000'), 'month': today.month, 'year': today.year},
        {'category': expense_cats['Utilities'], 'amount': Decimal('5000'), 'month': today.month, 'year': today.year},
        {'category': expense_cats['Entertainment'], 'amount': Decimal('4000'), 'month': today.month, 'year': today.year},
    ]

    for bud_data in budgets:
        Budget.objects.get_or_create(
            user=user,
            category=bud_data['category'],
            month=bud_data['month'],
            year=bud_data['year'],
            defaults={'amount': bud_data['amount']}
        )
    print('Sample budgets created.')

    print('\nSeed complete!')
    print('Login: demo@example.com / password123')


if __name__ == '__main__':
    seed()
