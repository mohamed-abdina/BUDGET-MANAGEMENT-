from django import forms
from .models import IncomeCategory, Income


class IncomeCategoryForm(forms.ModelForm):
    class Meta:
        model = IncomeCategory
        fields = ['name', 'color', 'icon']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Category name'}),
            'color': forms.TextInput(attrs={'type': 'color', 'class': 'form-control-color'}),
            'icon': forms.Select(attrs={'class': 'form-select'}),
        }


class IncomeForm(forms.ModelForm):
    class Meta:
        model = Income
        fields = ['category', 'amount', 'description', 'date']
        widgets = {
            'category': forms.Select(attrs={'class': 'form-select'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control', 'step': '0.01', 'min': '0.01', 'placeholder': '0.00'}),
            'description': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Description'}),
            'date': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
        }

    def __init__(self, user, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['category'].queryset = IncomeCategory.objects.filter(user=user)
