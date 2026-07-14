from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import IncomeCategory, Income
from .forms import IncomeCategoryForm, IncomeForm


@login_required
def income_list(request):
    incomes = Income.objects.filter(user=request.user).select_related('category')
    categories = IncomeCategory.objects.filter(user=request.user)

    # Filters
    category_id = request.GET.get('category')
    search = request.GET.get('search', '')
    month = request.GET.get('month')
    year = request.GET.get('year')

    if category_id:
        incomes = incomes.filter(category_id=category_id)
    if search:
        incomes = incomes.filter(description__icontains=search)
    if month and year:
        incomes = incomes.filter(date__month=month, date__year=year)

    total = sum(i.amount for i in incomes)

    return render(request, 'income/list.html', {
        'incomes': incomes,
        'categories': categories,
        'total': total,
        'search': search,
        'selected_category': category_id,
    })


@login_required
def income_create(request):
    if request.method == 'POST':
        form = IncomeForm(request.user, request.POST)
        if form.is_valid():
            income = form.save(commit=False)
            income.user = request.user
            income.save()
            messages.success(request, 'Income added successfully!')
            return redirect('income:list')
    else:
        form = IncomeForm(request.user)

    return render(request, 'income/form.html', {'form': form, 'title': 'Add Income'})


@login_required
def income_edit(request, pk):
    income = get_object_or_404(Income, pk=pk, user=request.user)
    if request.method == 'POST':
        form = IncomeForm(request.user, request.POST, instance=income)
        if form.is_valid():
            form.save()
            messages.success(request, 'Income updated successfully!')
            return redirect('income:list')
    else:
        form = IncomeForm(request.user, instance=income)

    return render(request, 'income/form.html', {'form': form, 'title': 'Edit Income'})


@login_required
def income_delete(request, pk):
    income = get_object_or_404(Income, pk=pk, user=request.user)
    if request.method == 'POST':
        income.delete()
        messages.success(request, 'Income deleted successfully!')
        return redirect('income:list')

    return render(request, 'income/confirm_delete.html', {'object': income})


@login_required
def income_categories(request):
    categories = IncomeCategory.objects.filter(user=request.user)

    if request.method == 'POST':
        form = IncomeCategoryForm(request.POST)
        if form.is_valid():
            category = form.save(commit=False)
            category.user = request.user
            category.save()
            messages.success(request, 'Category created successfully!')
            return redirect('income:categories')
    else:
        form = IncomeCategoryForm()

    return render(request, 'income/categories.html', {
        'categories': categories,
        'form': form,
    })


@login_required
def income_category_edit(request, pk):
    category = get_object_or_404(IncomeCategory, pk=pk, user=request.user)
    if request.method == 'POST':
        form = IncomeCategoryForm(request.POST, instance=category)
        if form.is_valid():
            form.save()
            messages.success(request, 'Category updated successfully!')
            return redirect('income:categories')
    else:
        form = IncomeCategoryForm(instance=category)

    return render(request, 'income/category_form.html', {'form': form, 'category': category})


@login_required
def income_category_delete(request, pk):
    category = get_object_or_404(IncomeCategory, pk=pk, user=request.user)
    if category.incomes.exists():
        messages.error(request, 'Cannot delete category with existing income entries.')
        return redirect('income:categories')

    if request.method == 'POST':
        category.delete()
        messages.success(request, 'Category deleted successfully!')
        return redirect('income:categories')

    return render(request, 'income/confirm_delete.html', {'object': category})
