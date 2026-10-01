import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Admin edit product screen
class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late int _selectedCategoryId;
  late double _rating;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageController = TextEditingController(text: widget.product.imagePath);
    _selectedCategoryId = widget.product.categoryId;
    _rating = widget.product.rating;
    _isAvailable = widget.product.isAvailable;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProduct = widget.product.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imagePath: _imageController.text.trim(),
      categoryId: _selectedCategoryId,
      rating: _rating,
      isAvailable: _isAvailable,
    );

    await context.read<ProductProvider>().updateProduct(updatedProduct);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
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
                  setState(() => _selectedCategoryId = value!);
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
                label: 'Image Path',
                hint: 'Enter image path',
                controller: _imageController,
              ),
              const SizedBox(height: 16),
              // Availability toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() => _isAvailable = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'UPDATE PRODUCT',
                onPressed: _updateProduct,
                icon: Icons.save_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
