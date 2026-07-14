# Ledgerline - Budget Management Application

A full-stack personal finance application for tracking income, expenses, and budgets with real-time visual analytics. Ships with a web frontend (Django), a REST API (DRF + JWT), and a native mobile companion app (Flutter).

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Python 3.14 + Django 6.0 + Django REST Framework |
| **Authentication** | SimpleJWT (email-based, 30-min access / 7-day refresh tokens) |
| **Database** | MySQL 8.0 (utf8mb4) |
| **Web Frontend** | Django Templates + Vanilla JavaScript |
| **Mobile App** | Flutter (Dart 3.11.4) |
| **Charts** | Chart.js 4.4 (Web) / fl_chart 0.68 (Flutter) |
| **Icons** | Tabler Icons 2.44 |
| **Fonts** | Manrope + IBM Plex Mono (Google Fonts) |
| **State Management** | Provider (Flutter) |
| **CORS** | django-cors-headers |

## Features

### Core Functionality
- **User Authentication** - Register, login, logout, forgot/reset password, profile management
- **Income Tracking** - Log income with categories, amounts, descriptions, and dates
- **Expense Tracking** - Log expenses with categories, amounts, descriptions, and dates
- **Budget Management** - Set monthly spending limits per expense category with real-time progress tracking
- **Financial Reports** - Monthly summaries, trend analysis (3/6/12 months), category breakdowns
- **Dashboard** - At-a-glance overview with key metrics and interactive charts

### Visualization
- **Bar Chart** - Income vs Expenses comparison (6-month trend)
- **Line Chart** - Monthly spending trend
- **Doughnut Chart** - Expense category breakdown
- **Polar Area Chart** - Budget usage per category
- **Progress Bars** - Budget tracking with color-coded states (green <80%, yellow 80-99%, red >=100%)

### UI/UX
- **Dark/Light Theme** - Toggle with localStorage persistence
- **Responsive Design** - Desktop sidebar layout + mobile bottom navigation (breakpoint: 860px)
- **Category Customization** - Custom colors (hex picker) and icons per category
- **Flash Messages** - Auto-dismissing success/error alerts
- **Password Visibility Toggle** - Eye icon on all password fields
- **Filter & Search** - Filter by category and search by description
- **Month/Year Selection** - Auto-submit selectors for budgets and reports
- **Empty States** - Placeholder UI when no data exists

### API & Mobile
- **REST API** - Full CRUD for all entities via DRF ViewSets
- **JWT Authentication** - Email-based token obtain/refresh/verify
- **Flutter Mobile App** - Complete native companion with auto token refresh
- **Multi-user Isolation** - All data scoped to authenticated user

## Setup

### Prerequisites

- Python 3.14+
- MySQL 8.0
- pip

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Database

Edit `.env` file with your MySQL credentials:

```
SECRET_KEY=your-secret-key
DEBUG=True
DB_NAME=budget_management
DB_USER=root
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=3306
```

### 3. Run Migrations

```bash
python manage.py migrate
```

### 4. Seed Demo Data

```bash
python scripts/seed.py
```

This creates a demo user with sample income, expenses, and budgets:
- **Email:** demo@example.com
- **Password:** password123

### 5. Start Server

```bash
python manage.py runserver
```

Visit: http://localhost:8000

### Flutter Mobile App (Optional)

```bash
cd flutter_app
flutter pub get
flutter run
```

The Flutter app connects to `http://10.0.2.2:8000` (Android emulator) by default. Configure the API URL in the Settings screen.

## Project Structure

```
budget_management/
├── budget_management/        # Django project settings, URLs, WSGI/ASGI
├── accounts/                 # User authentication (register, login, logout, profile, password reset)
├── income/                   # Income tracking (entries + categories with color/icon)
├── expenses/                 # Expense tracking (entries + categories with color/icon)
├── budgets/                  # Monthly budgets per expense category with progress tracking
├── dashboard/                # Dashboard overview with metrics and charts
├── reports/                  # Financial reports with configurable trend analysis
├── api/                      # REST API (DRF ViewSets + JWT auth)
├── templates/                # Django HTML templates (23 templates)
│   ├── base.html             # Master layout (sidebar + mobile nav)
│   ├── accounts/             # Login, register, forgot/reset password
│   ├── profile/              # User profile
│   ├── dashboard/            # Dashboard with charts
│   ├── income/               # Income list, form, categories, delete confirm
│   ├── expenses/             # Expense list, form, categories, delete confirm
│   ├── budgets/              # Budget list, form, delete confirm
│   └── reports/              # Reports with charts
├── static/                   # Static assets
│   ├── css/                  # 7 stylesheets (base, layout, auth, dashboard, income, budgets, profile)
│   └── js/                   # app.js (theme toggle, alerts, password toggle)
├── flutter_app/              # Flutter mobile companion app (49 Dart files)
│   └── lib/
│       ├── config/           # API endpoint configuration
│       ├── models/           # Data models (9 models)
│       ├── services/         # API communication with JWT auto-refresh
│       ├── providers/        # State management (auth, theme, income, expense, budget, report)
│       ├── screens/          # UI screens (auth, dashboard, income, expenses, budgets, reports, profile, settings)
│       ├── widgets/          # Reusable components (metric cards, badges, progress bars, etc.)
│       ├── theme/            # Theme configuration
│       └── utils/            # Validators and formatters
├── scripts/                  # Utility scripts
│   ├── seed.py               # Database seeder with demo data
│   ├── test_jwt.py           # JWT authentication smoke test
│   ├── debug_jwt.py          # JWT debugger
│   └── test_api.py           # API endpoint smoke test
├── media/                    # User uploads (currently unused)
├── .env                      # Environment variables
├── requirements.txt          # Python dependencies
└── manage.py                 # Django management script
```

## Django Apps

| App | Purpose | Models |
|-----|---------|--------|
| `accounts` | User authentication | `User` (extends AbstractUser) |
| `income` | Income tracking | `IncomeCategory`, `Income` |
| `expenses` | Expense tracking | `ExpenseCategory`, `Expense` |
| `budgets` | Budget management | `Budget` (with computed spent/remaining/percentage) |
| `dashboard` | Overview page | None |
| `reports` | Financial reports | None |
| `api` | REST API | None (uses other apps' models) |

## Models

### User
Extends Django's `AbstractUser`. Uses email as the primary identifier.

### IncomeCategory / ExpenseCategory
| Field | Type | Description |
|-------|------|-------------|
| user | ForeignKey | Owner |
| name | CharField(100) | Category name (unique per user) |
| color | CharField(7) | Hex color code (default: `#1D8763` income / `#C2483F` expense) |
| icon | CharField(50) | Tabler icon class (default: `ti-cash` income / `ti-shopping-cart` expense) |
| created_at | DateTimeField | Auto-set on creation |

### Income / Expense
| Field | Type | Description |
|-------|------|-------------|
| user | ForeignKey | Owner |
| category | ForeignKey | Linked category (RESTRICT on delete) |
| amount | DecimalField(15,2) | Monetary amount |
| description | CharField(255) | Description |
| date | DateField | Transaction date |
| created_at | DateTimeField | Auto-set on creation |

### Budget
| Field | Type | Description |
|-------|------|-------------|
| user | ForeignKey | Owner |
| category | ForeignKey | Expense category (CASCADE on delete) |
| amount | DecimalField(15,2) | Budget limit |
| month | IntegerField | Month (1-12) |
| year | IntegerField | Year |
| created_at | DateTimeField | Auto-set on creation |
| updated_at | DateTimeField | Auto-updated |

**Computed properties:**
- `spent` - Sum of expenses for the user/category/month/year
- `remaining` - `amount - spent`
- `percentage` - `min((spent / amount) * 100, 100)`

## URL Routes

### Web Frontend

| URL | View | Description |
|-----|------|-------------|
| `/` | Redirect | Redirects to dashboard |
| `/accounts/login/` | `accounts:login` | Login page |
| `/accounts/register/` | `accounts:register` | Registration page |
| `/accounts/logout/` | `accounts:logout` | Logout |
| `/accounts/forgot-password/` | `accounts:forgot_password` | Forgot password |
| `/accounts/reset-password/` | `accounts:reset_password` | Reset password |
| `/accounts/profile/` | `accounts:profile` | User profile |
| `/dashboard/` | `dashboard:index` | Dashboard overview |
| `/income/` | `income:list` | Income list |
| `/income/add/` | `income:create` | Add income |
| `/income/edit/<pk>/` | `income:edit` | Edit income |
| `/income/delete/<pk>/` | `income:delete` | Delete income |
| `/income/categories/` | `income:categories` | Income categories |
| `/income/categories/edit/<pk>/` | `income:category_edit` | Edit income category |
| `/income/categories/delete/<pk>/` | `income:category_delete` | Delete income category |
| `/expenses/` | `expenses:list` | Expense list |
| `/expenses/add/` | `expenses:create` | Add expense |
| `/expenses/edit/<pk>/` | `expenses:edit` | Edit expense |
| `/expenses/delete/<pk>/` | `expenses:delete` | Delete expense |
| `/expenses/categories/` | `expenses:categories` | Expense categories |
| `/expenses/categories/edit/<pk>/` | `expenses:category_edit` | Edit expense category |
| `/expenses/categories/delete/<pk>/` | `expenses:category_delete` | Delete expense category |
| `/budgets/` | `budgets:list` | Budget list |
| `/budgets/add/` | `budgets:create` | Add budget |
| `/budgets/edit/<pk>/` | `budgets:edit` | Edit budget |
| `/budgets/delete/<pk>/` | `budgets:delete` | Delete budget |
| `/reports/` | `reports:index` | Financial reports |
| `/admin/` | Django admin | Admin panel |

### REST API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/register/` | POST | Register new user |
| `/api/auth/login/` | POST | Obtain JWT token (email + password) |
| `/api/auth/refresh/` | POST | Refresh JWT token |
| `/api/auth/verify/` | POST | Verify JWT token |
| `/api/auth/profile/` | GET/PUT/PATCH | View/update user profile |
| `/api/income/` | GET/POST | List/create income entries |
| `/api/income/<pk>/` | GET/PUT/PATCH/DELETE | Retrieve/update/delete income |
| `/api/income/categories/` | GET/POST | List/create income categories |
| `/api/income/categories/<pk>/` | GET/PUT/PATCH/DELETE | Retrieve/update/delete income category |
| `/api/expense/` | GET/POST | List/create expense entries |
| `/api/expense/<pk>/` | GET/PUT/PATCH/DELETE | Retrieve/update/delete expense |
| `/api/expense/categories/` | GET/POST | List/create expense categories |
| `/api/expense/categories/<pk>/` | GET/PUT/PATCH/DELETE | Retrieve/update/delete expense category |
| `/api/budgets/` | GET/POST | List/create budgets |
| `/api/budgets/<pk>/` | GET/PUT/PATCH/DELETE | Retrieve/update/delete budget |
| `/api/reports/summary/` | GET | Monthly income/expense/balance summary |
| `/api/reports/monthly/` | GET | Multi-month trend data (query param: `months=3/6/12`) |
| `/api/reports/categories/` | GET | Expense category breakdown for a month |

**API Authentication:** `Bearer <token>` header. Token lifetime: 30 min access, 7-day refresh.

**API Filtering:** Income and expense endpoints support query params: `category`, `search`, `month`, `year`. Budget endpoints support `month` and `year`.

## Database Tables

| Table | App | Description |
|-------|-----|-------------|
| `users` | accounts | Custom user model |
| `income_categories` | income | User-defined income categories |
| `incomes` | income | Income entries |
| `expense_categories` | expenses | User-defined expense categories |
| `expenses` | expenses | Expense entries |
| `budgets` | budgets | Monthly budgets per expense category |

## Scripts

| Script | Description |
|--------|-------------|
| `python scripts/seed.py` | Creates demo user + sample data (4 income categories, 6 expense categories, 3 incomes, 7 expenses, 4 budgets) |
| `python scripts/test_jwt.py` | JWT authentication smoke test (register, obtain, access, refresh, verify) |
| `python scripts/debug_jwt.py` | JWT debugger for troubleshooting auth issues |
| `python scripts/test_api.py` | API endpoint smoke test (login, GET all endpoints, POST/DELETE) |

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| django | >=4.2, <7.0 | Web framework |
| djangorestframework | >=3.14 | REST API |
| django-cors-headers | >=4.3 | CORS support |
| mysqlclient | >=2.2 | MySQL driver |
| python-decouple | >=3.8 | Environment variable management |
| Pillow | >=10.0 | Image processing |
| rest_framework_simplejwt | (transitive) | JWT authentication |

## Currency

All monetary values are displayed in **KES** (Kenyan Shillings).

## Configuration

### JWT Settings
- Access token lifetime: 30 minutes
- Refresh token lifetime: 7 days
- Token rotation: Enabled
- Blacklist after rotation: Enabled
- Auth header: `Bearer <token>`

### CORS
- `CORS_ALLOW_ALL_ORIGINS = True` (for development)

### Timezone
- `TIME_ZONE = 'Africa/Nairobi'`
