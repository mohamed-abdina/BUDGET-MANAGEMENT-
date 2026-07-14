from django.contrib import admin
from .models import IncomeCategory, Income


@admin.register(IncomeCategory)
class IncomeCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'user', 'color', 'created_at']
    list_filter = ['user']
    search_fields = ['name']


@admin.register(Income)
class IncomeAdmin(admin.ModelAdmin):
    list_display = ['description', 'amount', 'category', 'date', 'user']
    list_filter = ['category', 'date', 'user']
    search_fields = ['description']
    date_hierarchy = 'date'
