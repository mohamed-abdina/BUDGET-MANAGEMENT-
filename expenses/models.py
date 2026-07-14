from django.db import models
from django.conf import settings


class ExpenseCategory(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='expense_categories')
    name = models.CharField(max_length=100)
    color = models.CharField(max_length=7, default='#C2483F')
    icon = models.CharField(max_length=50, default='ti-shopping-cart')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'expense_categories'
        unique_together = ['user', 'name']
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.user.email})"


class Expense(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='expenses')
    category = models.ForeignKey(ExpenseCategory, on_delete=models.RESTRICT, related_name='expenses')
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    description = models.CharField(max_length=255)
    date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'expenses'
        ordering = ['-date', '-created_at']

    def __str__(self):
        return f"{self.description} - KES {self.amount}"
