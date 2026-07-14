from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.db.models import Sum
from django.http import JsonResponse
from datetime import date, timedelta
from calendar import month_abbr
from income.models import Income, IncomeCategory
from expenses.models import Expense, ExpenseCategory
from budgets.models import Budget


@login_required
def dashboard_index(request):
    today = date.today()
    current_month = today.month
    current_year = today.year

    # Monthly totals
    month_income = Income.objects.filter(
        user=request.user,
        date__month=current_month,
        date__year=current_year
    ).aggregate(total=Sum('amount'))['total'] or 0

    month_expenses = Expense.objects.filter(
        user=request.user,
        date__month=current_month,
        date__year=current_year
    ).aggregate(total=Sum('amount'))['total'] or 0

    balance = month_income - month_expenses

    # Category breakdown (top 5 expense categories)
    category_summary = Expense.objects.filter(
        user=request.user,
        date__month=current_month,
        date__year=current_year
    ).values(
        'category__name', 'category__color', 'category__icon'
    ).annotate(
        total=Sum('amount')
    ).order_by('-total')[:5]

    # Recent transactions
    recent_incomes = Income.objects.filter(user=request.user).select_related('category')[:3]
    recent_expenses = Expense.objects.filter(user=request.user).select_related('category')[:3]

    # Budget status
    budgets = Budget.objects.filter(
        user=request.user,
        month=current_month,
        year=current_year
    ).select_related('category')

    total_budget = sum(b.amount for b in budgets)
    total_spent = sum(b.spent for b in budgets)

    # Format category summary for template
    categories = []
    max_total = max([c['total'] for c in category_summary], default=1) if category_summary else 1
    for cat in category_summary:
        categories.append({
            'name': cat['category__name'],
            'color': cat['category__color'],
            'icon': cat['category__icon'],
            'total': cat['total'],
            'percentage': (cat['total'] / max_total * 100) if max_total > 0 else 0,
        })

    # Monthly trend data (last 6 months)
    months = []
    income_data = []
    expense_data = []
    for i in range(5, -1, -1):
        m = current_month - i
        y = current_year
        if m <= 0:
            m += 12
            y -= 1
        months.append(month_abbr[m])
        inc = Income.objects.filter(user=request.user, date__month=m, date__year=y).aggregate(t=Sum('amount'))['t'] or 0
        exp = Expense.objects.filter(user=request.user, date__month=m, date__year=y).aggregate(t=Sum('amount'))['t'] or 0
        income_data.append(float(inc))
        expense_data.append(float(exp))

    # Expense category pie chart data
    pie_labels = [c['name'] for c in categories]
    pie_data = [float(c['total']) for c in categories]
    pie_colors = [c['color'] for c in categories]

    return render(request, 'dashboard/index.html', {
        'month_income': month_income,
        'month_expenses': month_expenses,
        'balance': balance,
        'categories': categories,
        'recent_incomes': recent_incomes,
        'recent_expenses': recent_expenses,
        'budgets': budgets,
        'total_budget': total_budget,
        'total_spent': total_spent,
        'current_month': current_month,
        'current_year': current_year,
        'chart_months': months,
        'chart_income': income_data,
        'chart_expenses': expense_data,
        'pie_labels': pie_labels,
        'pie_data': pie_data,
        'pie_colors': pie_colors,
    })
