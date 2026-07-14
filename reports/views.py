from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.db.models import Sum
from datetime import date
from calendar import month_name
from income.models import Income
from expenses.models import Expense
from budgets.models import Budget


@login_required
def reports_index(request):
    today = date.today()
    month = int(request.GET.get('month', today.month))
    year = int(request.GET.get('year', today.year))
    months = int(request.GET.get('months', 6))

    # Monthly summary for selected month
    income_total = Income.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).aggregate(total=Sum('amount'))['total'] or 0

    expense_total = Expense.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).aggregate(total=Sum('amount'))['total'] or 0

    balance = income_total - expense_total

    # Category breakdown
    categories = Expense.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).values(
        'category__name', 'category__color', 'category__icon'
    ).annotate(
        total=Sum('amount')
    ).order_by('-total')

    # Income category breakdown
    income_categories = Income.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).values(
        'category__name', 'category__color', 'category__icon'
    ).annotate(
        total=Sum('amount')
    ).order_by('-total')

    # Monthly trend data
    trend_months = []
    trend_income = []
    trend_expenses = []
    for i in range(months - 1, -1, -1):
        m = month - i
        y = year
        while m <= 0:
            m += 12
            y -= 1
        trend_months.append(f"{month_name[m]} {y}")
        inc = Income.objects.filter(
            user=request.user, date__month=m, date__year=y
        ).aggregate(t=Sum('amount'))['t'] or 0
        exp = Expense.objects.filter(
            user=request.user, date__month=m, date__year=y
        ).aggregate(t=Sum('amount'))['t'] or 0
        trend_income.append(float(inc))
        trend_expenses.append(float(exp))

    # Budget status for selected month
    budgets = Budget.objects.filter(
        user=request.user, month=month, year=year
    ).select_related('category')

    # Month/year selectors
    month_choices = [(i, month_name[i]) for i in range(1, 13)]
    year_choices = list(range(today.year - 2, today.year + 1))

    return render(request, 'reports/index.html', {
        'month': month,
        'year': year,
        'months': months,
        'income_total': income_total,
        'expense_total': expense_total,
        'balance': balance,
        'categories': categories,
        'income_categories': income_categories,
        'budgets': budgets,
        'trend_months': trend_months,
        'trend_income': trend_income,
        'trend_expenses': trend_expenses,
        'month_choices': month_choices,
        'year_choices': year_choices,
        'month_name': month_name[month],
    })
