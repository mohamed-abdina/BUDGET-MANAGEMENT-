from django import forms
from .models import Budget


class BudgetForm(forms.ModelForm):
    class Meta:
        model = Budget
        fields = ['category', 'amount', 'month', 'year']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control', 'step': '0.01', 'min': '0.01', 'placeholder': '0.00'}),
            'month': forms.Select(attrs={'class': 'form-select'}, choices=[
                (1, 'January'), (2, 'February'), (3, 'March'), (4, 'April'),
                (5, 'May'), (6, 'June'), (7, 'July'), (8, 'August'),
                (9, 'September'), (10, 'October'), (11, 'November'), (12, 'December'),
            ]),
            'year': forms.NumberInput(attrs={'class': 'form-control', 'min': '2020', 'max': '2030'}),
        }

    def __init__(self, user, *args, **kwargs):
        super().__init__(*args, **kwargs)
        from expenses.models import ExpenseCategory
        self.fields['category'].queryset = ExpenseCategory.objects.filter(user=user)
        # Default to current month/year
        if not self.instance.pk:
            from datetime import date
            today = date.today()
            self.fields['month'].initial = today.month
            self.fields['year'].initial = today.year
