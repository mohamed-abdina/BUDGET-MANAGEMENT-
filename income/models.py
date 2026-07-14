from django.db import models
from django.conf import settings


class IncomeCategory(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='income_categories')
    name = models.CharField(max_length=100)
    color = models.CharField(max_length=7, default='#1D8763')
    icon = models.CharField(max_length=50, default='ti-cash')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'income_categories'
        unique_together = ['user', 'name']
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.user.email})"


class Income(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='incomes')
    category = models.ForeignKey(IncomeCategory, on_delete=models.RESTRICT, related_name='incomes')
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    description = models.CharField(max_length=255)
    date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'incomes'
        ordering = ['-date', '-created_at']

    def __str__(self):
        return f"{self.description} - KES {self.amount}"
