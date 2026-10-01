import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../services/local_storage_service.dart';
import '../../utils/app_colors.dart';

/// Admin customer management screen
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final LocalStorageService _db = LocalStorageService.instance;
  List<UserModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      _customers = await _db.getAllCustomers();
    } catch (e) {
      // Handle error
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Customers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? Center(
                  child: Text(
                    'No customers found.',
                    style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCustomers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final customer = _customers[index];
                      return _buildCustomerCard(context, isDark, customer);
                    },
                  ),
                ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, bool isDark, UserModel customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark ? AppColors.goldAccent.withValues(alpha: 0.2) : AppColors.coffeeBrown.withValues(alpha: 0.1),
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.email,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              customer.phone,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              'Joined: ${DateFormat('MMM dd, yyyy').format(customer.createdAt)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showCustomerDetails(context, isDark, customer);
        },
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, bool isDark, UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', customer.email, isDark),
            _buildDetailRow('Phone', customer.phone, isDark),
            _buildDetailRow('Address', customer.address ?? 'Not set', isDark),
            _buildDetailRow('Role', customer.role, isDark),
            _buildDetailRow('Joined', DateFormat('MMM dd, yyyy').format(customer.createdAt), isDark),
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
