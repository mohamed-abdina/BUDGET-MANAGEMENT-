from django.urls import path
from . import views

app_name = 'calendar'

urlpatterns = [
    path('', views.calendar_index, name='index'),
    path('day/<int:year>/<int:month>/<int:day>/', views.calendar_day_detail, name='day_detail'),
    path('api/', views.calendar_api, name='api'),
]
