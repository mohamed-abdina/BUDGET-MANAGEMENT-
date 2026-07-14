from rest_framework import viewsets, status, serializers
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from django.db.models import Sum
from django.contrib.auth import get_user_model
from datetime import date
from .serializers import (
    IncomeCategorySerializer, ExpenseCategorySerializer,
    IncomeSerializer, ExpenseSerializer, BudgetSerializer
)
from income.models import IncomeCategory, Income
from expenses.models import ExpenseCategory, Expense
from budgets.models import Budget

User = get_user_model()


class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = 'email'

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError('No user found with this email.')

        if not user.check_password(password):
            raise serializers.ValidationError('Invalid password.')

        if not user.is_active:
            raise serializers.ValidationError('User account is disabled.')

        # Bypass parent validate (which re-authenticates by username)
        # and directly generate tokens
        refresh = self.get_token(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }


class EmailTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    email = request.data.get('email', '').strip()
    password = request.data.get('password', '')
    first_name = request.data.get('first_name', '')

    if not email or not password:
        return Response({'error': 'Email and password are required.'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(email=email).exists():
        return Response({'error': 'A user with this email already exists.'}, status=status.HTTP_400_BAD_REQUEST)

    username = email.split('@')[0]
    base_username = username
    counter = 1
    while User.objects.filter(username=username).exists():
        username = f'{base_username}{counter}'
        counter += 1

    user = User.objects.create_user(
        username=username,
        email=email,
        password=password,
        first_name=first_name,
    )
    return Response({'message': 'Account created successfully.', 'email': user.email}, status=status.HTTP_201_CREATED)


class IncomeCategoryViewSet(viewsets.ModelViewSet):
    serializer_class = IncomeCategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return IncomeCategory.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ExpenseCategoryViewSet(viewsets.ModelViewSet):
    serializer_class = ExpenseCategorySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return ExpenseCategory.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class IncomeViewSet(viewsets.ModelViewSet):
    serializer_class = IncomeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Income.objects.filter(user=self.request.user).select_related('category')
        category = self.request.query_params.get('category')
        search = self.request.query_params.get('search')
        month = self.request.query_params.get('month')
        year = self.request.query_params.get('year')

        if category:
            queryset = queryset.filter(category_id=category)
        if search:
            queryset = queryset.filter(description__icontains=search)
        if month and year:
            queryset = queryset.filter(date__month=month, date__year=year)
        return queryset

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ExpenseViewSet(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Expense.objects.filter(user=self.request.user).select_related('category')
        category = self.request.query_params.get('category')
        search = self.request.query_params.get('search')
        month = self.request.query_params.get('month')
        year = self.request.query_params.get('year')

        if category:
            queryset = queryset.filter(category_id=category)
        if search:
            queryset = queryset.filter(description__icontains=search)
        if month and year:
            queryset = queryset.filter(date__month=month, date__year=year)
        return queryset

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class BudgetViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Budget.objects.filter(user=self.request.user).select_related('category')
        month = self.request.query_params.get('month')
        year = self.request.query_params.get('year')

        if month and year:
            queryset = queryset.filter(month=month, year=year)
        return queryset

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def reports_summary(request):
    today = date.today()
    month = int(request.query_params.get('month', today.month))
    year = int(request.query_params.get('year', today.year))

    income_total = Income.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).aggregate(total=Sum('amount'))['total'] or 0

    expense_total = Expense.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).aggregate(total=Sum('amount'))['total'] or 0

    return Response({
        'income': float(income_total),
        'expenses': float(expense_total),
        'balance': float(income_total - expense_total),
        'month': month,
        'year': year,
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def reports_monthly(request):
    months = int(request.query_params.get('months', 6))
    today = date.today()

    data = []
    for i in range(months - 1, -1, -1):
        m = today.month - i
        y = today.year
        while m <= 0:
            m += 12
            y -= 1

        income = Income.objects.filter(
            user=request.user, date__month=m, date__year=y
        ).aggregate(total=Sum('amount'))['total'] or 0

        expense = Expense.objects.filter(
            user=request.user, date__month=m, date__year=y
        ).aggregate(total=Sum('amount'))['total'] or 0

        data.append({
            'month': m,
            'year': y,
            'income': float(income),
            'expense': float(expense),
            'balance': float(income - expense),
        })

    return Response(data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def reports_categories(request):
    today = date.today()
    month = int(request.query_params.get('month', today.month))
    year = int(request.query_params.get('year', today.year))

    categories = Expense.objects.filter(
        user=request.user, date__month=month, date__year=year
    ).values(
        'category__name', 'category__color'
    ).annotate(
        total=Sum('amount')
    ).order_by('-total')

    return Response(list(categories))


@api_view(['GET', 'PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def profile_view(request):
    user = request.user
    if request.method == 'GET':
        return Response({
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'date_joined': user.date_joined.isoformat(),
        })

    data = request.data
    if 'first_name' in data:
        user.first_name = data['first_name']
    if 'last_name' in data:
        user.last_name = data['last_name']
    if 'email' in data and data['email'] != user.email:
        if User.objects.filter(email=data['email']).exclude(id=user.id).exists():
            return Response({'error': 'Email already in use.'}, status=status.HTTP_400_BAD_REQUEST)
        user.email = data['email']
        user.username = data['email'].split('@')[0]
    user.save()
    return Response({
        'id': user.id,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'date_joined': user.date_joined.isoformat(),
    })
