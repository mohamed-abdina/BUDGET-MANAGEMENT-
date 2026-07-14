from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.db.models import Sum
from django.http import JsonResponse
from datetime import date
import calendar as cal_mod
from income.models import Income
from expenses.models import Expense


@login_required
def calendar_index(request):
    today = date.today()
    year = int(request.GET.get('year', today.year))
    month = int(request.GET.get('month', today.month))

    if month < 1:
        month = 12
        year -= 1
    elif month > 12:
        month = 1
        year += 1

    month_names = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ]

    first_day, num_days = cal_mod.monthrange(year, month)

    cal_days = []
    for day in range(1, num_days + 1):
        d = date(year, month, day)
        day_income = Income.objects.filter(
            user=request.user, date=d
        ).aggregate(total=Sum('amount'))['total'] or 0
        day_expense = Expense.objects.filter(
            user=request.user, date=d
        ).aggregate(total=Sum('amount'))['total'] or 0

        cal_days.append({
            'day': day,
            'date': d,
            'is_today': d == today,
            'income': day_income,
            'expense': day_expense,
            'has_income': day_income > 0,
            'has_expense': day_expense > 0,
            'has_both': day_income > 0 and day_expense > 0,
        })

    month_income = Income.objects.filter(
        user=request.user, date__year=year, date__month=month
    ).aggregate(total=Sum('amount'))['total'] or 0

    month_expense = Expense.objects.filter(
        user=request.user, date__year=year, date__month=month
    ).aggregate(total=Sum('amount'))['total'] or 0

    return render(request, 'calendar/index.html', {
        'year': year,
        'month': month,
        'month_name': month_names[month],
        'cal_days': cal_days,
        'first_day': first_day,
        'num_days': num_days,
        'month_income': month_income,
        'month_expense': month_expense,
        'today': today,
    })


@login_required
def calendar_day_detail(request, year, month, day):
    d = date(year, month, day)
    incomes = Income.objects.filter(user=request.user, date=d).select_related('category')
    expenses = Expense.objects.filter(user=request.user, date=d).select_related('category')
    return render(request, 'calendar/day_detail.html', {
        'date': d,
        'incomes': incomes,
        'expenses': expenses,
        'year': year,
        'month': month,
        'day': day,
    })


@login_required
def calendar_api(request):
    """API endpoint for calendar data (used by mobile or AJAX)."""
    today = date.today()
    year = int(request.GET.get('year', today.year))
    month = int(request.GET.get('month', today.month))

    first_day, num_days = cal_mod.monthrange(year, month)

    days = []
    for day in range(1, num_days + 1):
        d = date(year, month, day)
        day_income = Income.objects.filter(
            user=request.user, date=d
        ).aggregate(total=Sum('amount'))['total'] or 0
        day_expense = Expense.objects.filter(
            user=request.user, date=d
        ).aggregate(total=Sum('amount'))['total'] or 0

        days.append({
            'day': day,
            'date': d.isoformat(),
            'income': float(day_income),
            'expense': float(day_expense),
        })

    return JsonResponse({
        'year': year,
        'month': month,
        'first_day': first_day,
        'num_days': num_days,
        'days': days,
    })
