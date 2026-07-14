from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import Budget
from .forms import BudgetForm


@login_required
def budget_list(request):
    from datetime import date
    today = date.today()
    month = int(request.GET.get('month', today.month))
    year = int(request.GET.get('year', today.year))

    budgets = Budget.objects.filter(
        user=request.user,
        month=month,
        year=year
    ).select_related('category')

    total_budget = sum(b.amount for b in budgets)
    total_spent = sum(b.spent for b in budgets)

    # Pie chart data
    pie_labels = [b.category.name for b in budgets]
    pie_budget = [float(b.amount) for b in budgets]
    pie_spent = [float(b.spent) for b in budgets]
    pie_colors = [b.category.color for b in budgets]

    return render(request, 'budgets/list.html', {
        'budgets': budgets,
        'total_budget': total_budget,
        'total_spent': total_spent,
        'current_month': month,
        'current_year': year,
        'pie_labels': pie_labels,
        'pie_budget': pie_budget,
        'pie_spent': pie_spent,
        'pie_colors': pie_colors,
    })


@login_required
def budget_create(request):
    if request.method == 'POST':
        form = BudgetForm(request.user, request.POST)
        if form.is_valid():
            budget = form.save(commit=False)
            budget.user = request.user
            budget.save()
            messages.success(request, 'Budget created successfully!')
            return redirect('budgets:list')
    else:
        form = BudgetForm(request.user)

    return render(request, 'budgets/form.html', {'form': form, 'title': 'Add Budget'})


@login_required
def budget_edit(request, pk):
    budget = get_object_or_404(Budget, pk=pk, user=request.user)
    if request.method == 'POST':
        form = BudgetForm(request.user, request.POST, instance=budget)
        if form.is_valid():
            form.save()
            messages.success(request, 'Budget updated successfully!')
            return redirect('budgets:list')
    else:
        form = BudgetForm(request.user, instance=budget)

    return render(request, 'budgets/form.html', {'form': form, 'title': 'Edit Budget'})


@login_required
def budget_delete(request, pk):
    budget = get_object_or_404(Budget, pk=pk, user=request.user)
    if request.method == 'POST':
        budget.delete()
        messages.success(request, 'Budget deleted successfully!')
        return redirect('budgets:list')

    return render(request, 'budgets/confirm_delete.html', {'object': budget})
