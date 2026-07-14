from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenRefreshView,
    TokenVerifyView,
)
from . import views

router = DefaultRouter()
router.register(r'income/categories', views.IncomeCategoryViewSet, basename='api-income-category')
router.register(r'income', views.IncomeViewSet, basename='api-income')
router.register(r'expense/categories', views.ExpenseCategoryViewSet, basename='api-expense-category')
router.register(r'expense', views.ExpenseViewSet, basename='api-expense')
router.register(r'budgets', views.BudgetViewSet, basename='api-budget')

urlpatterns = [
    # JWT Auth
    path('auth/register/', views.register_view, name='api-register'),
    path('auth/login/', views.EmailTokenObtainPairView.as_view(), name='api-login'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='api-refresh'),
    path('auth/verify/', TokenVerifyView.as_view(), name='api-verify'),
    # Profile
    path('auth/profile/', views.profile_view, name='api-profile'),
    # Router
    path('', include(router.urls)),
    # Reports
    path('reports/summary/', views.reports_summary, name='reports-summary'),
    path('reports/monthly/', views.reports_monthly, name='reports-monthly'),
    path('reports/categories/', views.reports_categories, name='reports-categories'),
]
