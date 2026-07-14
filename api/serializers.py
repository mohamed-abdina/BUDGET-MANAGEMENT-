from rest_framework import serializers
from income.models import IncomeCategory, Income
from expenses.models import ExpenseCategory, Expense
from budgets.models import Budget


class IncomeCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = IncomeCategory
        fields = ['id', 'name', 'color', 'icon']


class ExpenseCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseCategory
        fields = ['id', 'name', 'color', 'icon']


class IncomeSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_color = serializers.CharField(source='category.color', read_only=True)

    class Meta:
        model = Income
        fields = ['id', 'category', 'category_name', 'category_color', 'amount', 'description', 'date']


class ExpenseSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_color = serializers.CharField(source='category.color', read_only=True)

    class Meta:
        model = Expense
        fields = ['id', 'category', 'category_name', 'category_color', 'amount', 'description', 'date']


class BudgetSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_color = serializers.CharField(source='category.color', read_only=True)
    spent = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    remaining = serializers.DecimalField(max_digits=15, decimal_places=2, read_only=True)
    percentage = serializers.FloatField(read_only=True)

    class Meta:
        model = Budget
        fields = ['id', 'category', 'category_name', 'category_color', 'amount', 'month', 'year', 'spent', 'remaining', 'percentage']
