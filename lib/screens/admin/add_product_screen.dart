import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Admin add product screen
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  int? _selectedCategoryId;
  double _rating = 4.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.loadProducts();
      if (provider.categories.isNotEmpty && _selectedCategoryId == null) {
        setState(() {
          _selectedCategoryId = provider.categories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final product = ProductModel(
      categoryId: _selectedCategoryId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imagePath: _imageController.text.trim().isEmpty ? 'placeholder' : _imageController.text.trim(),
      rating: _rating,
      isAvailable: true,
      createdAt: DateTime.now(),
    );

    await context.read<ProductProvider>().addProduct(product);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Enter product description',
                controller: _descriptionController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Price',
                hint: 'Enter price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required.';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid price.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category dropdown
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: provider.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Rating slider
              Text(
                'Rating: ${_rating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 10,
                label: _rating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() => _rating = value);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Image Path (Optional)',
                hint: 'e.g., biscoff_latte',
                controller: _imageController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'ADD PRODUCT',
                onPressed: _addProduct,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
