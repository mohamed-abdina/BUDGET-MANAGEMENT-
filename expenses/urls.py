from django.urls import path
from . import views

app_name = 'expenses'

urlpatterns = [
    path('', views.expense_list, name='list'),
    path('add/', views.expense_create, name='create'),
    path('edit/<int:pk>/', views.expense_edit, name='edit'),
    path('delete/<int:pk>/', views.expense_delete, name='delete'),
    path('categories/', views.expense_categories, name='categories'),
    path('categories/edit/<int:pk>/', views.expense_category_edit, name='category_edit'),
    path('categories/delete/<int:pk>/', views.expense_category_delete, name='category_delete'),
]
