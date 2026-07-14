from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import ExpenseCategory, Expense
from .forms import ExpenseCategoryForm, ExpenseForm


@login_required
def expense_list(request):
    expenses = Expense.objects.filter(user=request.user).select_related('category')
    categories = ExpenseCategory.objects.filter(user=request.user)

    # Filters
    category_id = request.GET.get('category')
    search = request.GET.get('search', '')
    month = request.GET.get('month')
    year = request.GET.get('year')

    if category_id:
        expenses = expenses.filter(category_id=category_id)
    if search:
        expenses = expenses.filter(description__icontains=search)
    if month and year:
        expenses = expenses.filter(date__month=month, date__year=year)

    total = sum(e.amount for e in expenses)

    return render(request, 'expenses/list.html', {
        'expenses': expenses,
        'categories': categories,
        'total': total,
        'search': search,
        'selected_category': category_id,
    })


@login_required
def expense_create(request):
    if request.method == 'POST':
        form = ExpenseForm(request.user, request.POST)
        if form.is_valid():
            expense = form.save(commit=False)
            expense.user = request.user
            expense.save()
            messages.success(request, 'Expense added successfully!')
            return redirect('expenses:list')
    else:
        form = ExpenseForm(request.user)

    return render(request, 'expenses/form.html', {'form': form, 'title': 'Add Expense'})


@login_required
def expense_edit(request, pk):
    expense = get_object_or_404(Expense, pk=pk, user=request.user)
    if request.method == 'POST':
        form = ExpenseForm(request.user, request.POST, instance=expense)
        if form.is_valid():
            form.save()
            messages.success(request, 'Expense updated successfully!')
            return redirect('expenses:list')
    else:
        form = ExpenseForm(request.user, instance=expense)

    return render(request, 'expenses/form.html', {'form': form, 'title': 'Edit Expense'})


@login_required
def expense_delete(request, pk):
    expense = get_object_or_404(Expense, pk=pk, user=request.user)
    if request.method == 'POST':
        expense.delete()
        messages.success(request, 'Expense deleted successfully!')
        return redirect('expenses:list')

    return render(request, 'expenses/confirm_delete.html', {'object': expense})


@login_required
def expense_categories(request):
    categories = ExpenseCategory.objects.filter(user=request.user)

    if request.method == 'POST':
        form = ExpenseCategoryForm(request.POST)
        if form.is_valid():
            category = form.save(commit=False)
            category.user = request.user
            category.save()
            messages.success(request, 'Category created successfully!')
            return redirect('expenses:categories')
    else:
        form = ExpenseCategoryForm()

    return render(request, 'expenses/categories.html', {
        'categories': categories,
        'form': form,
    })


@login_required
def expense_category_edit(request, pk):
    category = get_object_or_404(ExpenseCategory, pk=pk, user=request.user)
    if request.method == 'POST':
        form = ExpenseCategoryForm(request.POST, instance=category)
        if form.is_valid():
            form.save()
            messages.success(request, 'Category updated successfully!')
            return redirect('expenses:categories')
    else:
        form = ExpenseCategoryForm(instance=category)

    return render(request, 'expenses/category_form.html', {'form': form, 'category': category})


@login_required
def expense_category_delete(request, pk):
    category = get_object_or_404(ExpenseCategory, pk=pk, user=request.user)
    if category.expenses.exists():
        messages.error(request, 'Cannot delete category with existing expense entries.')
        return redirect('expenses:categories')

    if request.method == 'POST':
        category.delete()
        messages.success(request, 'Category deleted successfully!')
        return redirect('expenses:categories')

    return render(request, 'expenses/confirm_delete.html', {'object': category})
