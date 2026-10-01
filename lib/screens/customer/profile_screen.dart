import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import 'orders_screen.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.goldAccent.withValues(alpha: 0.2), AppColors.orangeAccent.withValues(alpha: 0.1)]
                      : [AppColors.coffeeBrown, AppColors.goldAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User info
            _buildInfoCard(
              context,
              isDark,
              title: 'Personal Information',
              children: [
                _buildInfoRow(Icons.person_outlined, 'Name', user?.name ?? '', isDark),
                _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? '', isDark),
                _buildInfoRow(Icons.phone_outlined, 'Phone', user?.phone ?? '', isDark),
                _buildInfoRow(Icons.location_on_outlined, 'Address', user?.address ?? 'Not set', isDark),
              ],
            ),
            const SizedBox(height: 16),

            // Settings
            _buildInfoCard(
              context,
              isDark,
              title: 'Settings & Demo Controls',
              children: [
                _buildActionRow(
                  context,
                  isDark,
                  icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: isDark ? 'Dark blue midnight enabled' : 'Clean light enabled',
                  onTap: () => themeProvider.toggleTheme(),
                  showSwitch: true,
                  switchValue: isDark,
                ),
                _buildActionRow(
                  context,
                  isDark,
                  icon: Icons.receipt_long_rounded,
                  title: 'My Orders',
                  subtitle: 'Live order tracking & history',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()),
                    );
                  },
                ),
                _buildActionRow(
                  context,
                  isDark,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Switch to Local Admin',
                  subtitle: 'Open Admin Dashboard & live tracking',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminDashboard()),
                    );
                  },
                ),
                _buildActionRow(
                  context,
                  isDark,
                  icon: Icons.school_rounded,
                  title: 'CSE101 Final Project Details',
                  subtitle: 'Group 4: Kristian Dale, Stephanie, Melea',
                  onTap: () => _showProjectDialog(context, isDark),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account actions
            _buildInfoCard(
              context,
              isDark,
              title: 'Account',
              children: [
                _buildActionRow(
                  context,
                  isDark,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () => _showChangePasswordDialog(context, isDark),
                ),
                _buildActionRow(
                  context,
                  isDark,
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () => _showLogoutDialog(context, isDark),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App version
            Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark, {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showSwitch = false,
    bool switchValue = false,
  }) {
    final color = isDestructive ? AppColors.error : (isDark ? AppColors.darkText : AppColors.lightText);

    return InkWell(
      onTap: showSwitch ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showSwitch)
              Switch(
                value: switchValue,
                onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
              )
            else if (!isDestructive)
              Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 8 characters.')),
                );
                return;
              }
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match.')),
                );
                return;
              }

              final auth = context.read<AuthProvider>();
              final success = await auth.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );

              if (!context.mounted) return;

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(auth.error ?? 'Failed to change password.')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showProjectDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppColors.electricBlue),
            SizedBox(width: 10),
            Text('CSE101 Final Project'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Ordering App (Project #4)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Assigned Team Members:'),
            const SizedBox(height: 4),
            const Text(
              '• Kristian Dale\n• Stephanie\n• Melea',
              style: TextStyle(fontWeight: FontWeight.bold, height: 1.4),
            ),
            const Divider(height: 24),
            const Text('Project Specifications:'),
            const SizedBox(height: 4),
            const Text(
              '✓ In-memory state management (OrderProvider)\n'
              '✓ Zero database (No Firebase, No SQL, No Supabase)\n'
              '✓ Real-time status sync between Customer & Admin\n'
              '✓ Aesthetic Dark Blue & Foodpanda styling\n'
              '✓ Cart, Checkout, Order Tracking & Local Admin',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

