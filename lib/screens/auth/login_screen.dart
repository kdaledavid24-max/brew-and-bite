import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../customer/main_screen.dart';
import '../admin/admin_dashboard.dart';
import 'register_screen.dart';

/// Login screen for customers and local admin
/// CSE101 Final Project - Group 4 (Kristian Dale, Stephanie, Melea)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login({String? email, String? password}) async {
    final loginEmail = email ?? _emailController.text.trim();
    final loginPass = password ?? _passwordController.text;

    if (email == null) {
      if (!_formKey.currentState!.validate()) return;
    } else {
      _emailController.text = loginEmail;
      _passwordController.text = loginPass;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(loginEmail, loginPass);

    if (!mounted) return;

    if (success) {
      if (auth.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Invalid email or password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // CSE101 Final Project Header Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.softIce,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.electricBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded,
                            size: 16, color: AppColors.electricBlue),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CSE101 Final Project • Group 4',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.electricBlue,
                              ),
                            ),
                            Text(
                              'Kristian Dale • Stephanie • Melea',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Aesthetic Logo in Deep Navy Circle
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.midnightNavy, AppColors.deepNavy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.midnightNavy.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      size: 46,
                      color: AppColors.skyAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // App Brand Name
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Local Food Ordering & Live Admin Tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Demo Accounts Section (1-Tap Demonstration)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.softBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Demo Accounts (1-Tap Login):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.midnightNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickLoginChip(
                            label: 'Kristian (Customer)',
                            icon: Icons.person_rounded,
                            color: AppColors.electricBlue,
                            onTap: () => _login(
                              email: 'kristian@brewandbite.com',
                              password: 'kristian123',
                            ),
                          ),
                          _buildQuickLoginChip(
                            label: 'Stephanie',
                            icon: Icons.person_outline_rounded,
                            color: const Color(0xFF0284C7),
                            onTap: () => _login(
                              email: 'stephanie@brewandbite.com',
                              password: 'stephanie123',
                            ),
                          ),
                          _buildQuickLoginChip(
                            label: 'Melea',
                            icon: Icons.person_outline_rounded,
                            color: const Color(0xFF0284C7),
                            onTap: () => _login(
                              email: 'melea@brewandbite.com',
                              password: 'melea123',
                            ),
                          ),
                          _buildQuickLoginChip(
                            label: '⚡ Local Admin',
                            icon: Icons.admin_panel_settings_rounded,
                            color: AppColors.orangeAccent,
                            isFeatured: true,
                            onTap: () => _login(
                              email: AppConstants.adminEmail,
                              password: AppConstants.adminPassword,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Email field
                CustomTextField(
                  label: 'Email',
                  hint: 'admin@brewandbite.com or customer email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password (e.g. admin123)',
                  controller: _passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  prefixIcon: Icons.lock_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // LOGIN BUTTON
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return CustomButton(
                      text: 'SIGN IN',
                      onPressed: () => _login(),
                      isLoading: auth.isLoading,
                      icon: Icons.login_rounded,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFeatured = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isFeatured ? 0.18 : 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: isFeatured ? 0.5 : 0.25),
            width: isFeatured ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isFeatured ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
