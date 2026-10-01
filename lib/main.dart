import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/main_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrewAndBiteApp());
}

/// Brew & Bite - Coffee Shop Food Ordering System
/// CSE101 Final Project - Group 4 (Kristian Dale, Stephanie, Melea)
class BrewAndBiteApp extends StatelessWidget {
  const BrewAndBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        // Shared local in-memory order provider for Customer and Admin
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp(
                title: 'Brew & Bite',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode:
                    themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: _getHomeScreen(authProvider),
              );
            },
          );
        },
      ),
    );
  }

  /// Determine which screen to show based on auth state
  Widget _getHomeScreen(AuthProvider authProvider) {
    if (authProvider.isLoggedIn) {
      if (authProvider.isAdmin) {
        return const AdminDashboard();
      }
      return const MainScreen();
    }
    return const LoginScreen();
  }
}
