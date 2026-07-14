from django.urls import path
from . import views

app_name = 'income'

urlpatterns = [
    path('', views.income_list, name='list'),
    path('add/', views.income_create, name='create'),
    path('edit/<int:pk>/', views.income_edit, name='edit'),
    path('delete/<int:pk>/', views.income_delete, name='delete'),
    path('categories/', views.income_categories, name='categories'),
    path('categories/edit/<int:pk>/', views.income_category_edit, name='category_edit'),
    path('categories/delete/<int:pk>/', views.income_category_delete, name='category_delete'),
]
