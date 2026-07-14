from django.urls import path
from . import views

app_name = 'budgets'

urlpatterns = [
    path('', views.budget_list, name='list'),
    path('add/', views.budget_create, name='create'),
    path('edit/<int:pk>/', views.budget_edit, name='edit'),
    path('delete/<int:pk>/', views.budget_delete, name='delete'),
]
