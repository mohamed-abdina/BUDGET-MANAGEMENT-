from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ['email', 'first_name', 'is_active', 'date_joined']
    list_filter = ['is_active', 'date_joined']
    search_fields = ['email', 'first_name']
    ordering = ['-date_joined']
    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {'fields': ()}),
    )
