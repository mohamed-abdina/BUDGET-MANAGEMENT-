from django.db import models
from django.conf import settings


class Budget(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='budgets')
    category = models.ForeignKey('expenses.ExpenseCategory', on_delete=models.CASCADE, related_name='budgets')
    amount = models.DecimalField(max_digits=15, decimal_places=2)
    month = models.IntegerField()
    year = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'budgets'
        unique_together = ['user', 'category', 'month', 'year']
        ordering = ['-year', '-month']

    def __str__(self):
        return f"{self.category.name} - KES {self.amount} ({self.month}/{self.year})"

    @property
    def spent(self):
        from expenses.models import Expense
        return Expense.objects.filter(
            user=self.user,
            category=self.category,
            date__month=self.month,
            date__year=self.year
        ).aggregate(total=models.Sum('amount'))['total'] or 0

    @property
    def remaining(self):
        return self.amount - self.spent

    @property
    def percentage(self):
        if self.amount == 0:
            return 0
        return min(round((self.spent / self.amount) * 100, 1), 100)
