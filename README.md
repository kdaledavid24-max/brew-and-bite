# Brew & Bite - Coffee Shop Food Ordering System

A complete, functional Flutter coffee shop food ordering application with customer ordering system and admin management dashboard.

**Tagline:** "Freshly Brewed. Freshly Made."

---

## Features

### Customer Features
- User registration and login
- Browse products by category (Coffee, Salad, Pasta)
- Search products
- Filter by category
- View product details with ratings
- Add products to cart with quantity selection
- Special instructions for orders
- Shopping cart with quantity management
- Checkout with pickup/delivery options
- Multiple payment methods (Cash, GCash, Card - demo)
- Order tracking with visual status progress
- Order history (Active, Completed, Cancelled)
- Profile management
- Dark/Light mode toggle

### Admin Features
- Admin login (separate from customer accounts)
- Dashboard with statistics (today's orders, sales, products, customers)
- Product management (add, edit, delete, toggle availability)
- Order management (view all orders, update status)
- Customer management (view customer information)
- Sales report with analytics

---

## Technology Stack

- **Framework:** Flutter 3.47+
- **Language:** Dart 3.13+
- **Local Storage:** SharedPreferences (JSON) - no database, no backend
- **State Management:** Provider
- **Theme & Session Persistence:** SharedPreferences

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── category_model.dart
│   ├── cart_item_model.dart
│   ├── order_model.dart
│   └── order_item_model.dart
├── services/                    # Business logic & data layer
│   ├── local_storage_service.dart # SharedPreferences (JSON) storage
│   ├── auth_service.dart        # Authentication logic
│   ├── product_service.dart     # Product operations
│   └── order_service.dart       # Order operations
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   └── theme_provider.dart
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── customer/
│   │   ├── main_screen.dart     # Bottom nav + home
│   │   ├── home_screen.dart
│   │   ├── category_screen.dart
│   │   ├── product_details_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── order_success_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── order_details_screen.dart
│   │   └── profile_screen.dart
│   └── admin/
│       ├── admin_dashboard.dart
│       ├── manage_products_screen.dart
│       ├── add_product_screen.dart
│       ├── edit_product_screen.dart
│       ├── manage_orders_screen.dart
│       ├── manage_users_screen.dart
│       └── sales_screen.dart
├── widgets/                     # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── product_card.dart
│   ├── category_card.dart
│   └── order_card.dart
├── utils/                       # App configuration
│   ├── app_colors.dart          # Color palette
│   ├── app_theme.dart           # Theme configuration
│   └── constants.dart           # App constants
└── routes/
    └── app_routes.dart          # Route names
```

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.47+ installed
- Android SDK (for Android builds)
- VS Code or Android Studio (recommended)

### Installation

1. **Clone or download the project**

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Build APK:**
   ```bash
   flutter build apk --release
   ```

---

## Default Login Credentials

### Admin Account
| Field    | Value                  |
|----------|------------------------|
| Email    | admin@brewandbite.com  |
| Password | admin123               |

### Customer Account
Register a new account through the app's registration screen.

---

## Local Storage

The app uses **Flutter SharedPreferences** for local data persistence - no database and no internet connection are needed. Every collection is saved as a JSON string under its own key.

On first launch the storage is automatically seeded with:

- Default admin account
- 3 categories (Coffee, Salad, Pasta)
- 11 sample products

### Stored Collections

| Key            | Description                        |
|----------------|------------------------------------|
| bb_users       | Customer and admin accounts        |
| bb_categories  | Product categories                 |
| bb_products    | Menu items                         |
| bb_orders      | Customer orders                    |
| bb_order_items | Individual items within orders     |

The storage layer lives in `lib/services/local_storage_service.dart`.

---

## Customization Guide

### Change App Name
Edit `lib/utils/constants.dart`:
```dart
static const String appName = 'Brew & Bite';
```

### Change Colors
Edit `lib/utils/app_colors.dart` - modify the color values.

### Change Delivery Fee
Edit `lib/utils/constants.dart`:
```dart
static const double deliveryFee = 30.0;
```

### Change Admin Credentials
Edit `lib/utils/constants.dart`:
```dart
static const String adminEmail = 'admin@brewandbite.com';
static const String adminPassword = 'admin123';
```

### Add/Edit Products
Use the Admin Dashboard → Manage Products, or edit the seed data in `lib/services/local_storage_service.dart` (then clear the app's data to re-seed).

### Change Currency
Edit `lib/utils/constants.dart`:
```dart
static const String currencySymbol = '₱';
```

---

## How It Works

### Customer Flow
1. Register a new account or login
2. Browse products on the home screen or by category
3. Search for specific products
4. Tap a product to view details
5. Add products to cart with desired quantity
6. Review cart and proceed to checkout
7. Select pickup or delivery
8. Choose payment method
9. Place order and receive order number
10. Track order status in real-time

### Admin Flow
1. Login with admin credentials
2. View dashboard statistics
3. Manage products (add, edit, delete)
4. View and update order statuses
5. View customer information
6. Check sales reports

### Order Status Flow
**Pickup:** Pending → Confirmed → Preparing → Ready → Completed

**Delivery:** Pending → Confirmed → Preparing → Out for Delivery → Delivered

---

## Dependencies

| Package             | Purpose                          |
|---------------------|----------------------------------|
| provider            | State management                 |
| shared_preferences | Local storage, theme & session persistence |
| intl                | Date formatting                  |

---

## Building for Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

---

## License

This project is created for educational purposes as a school project.
