import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'balance_service.dart';
import './category_service.dart';
import './category_model.dart';
import '../services/api_services.dart';

class AddCategory extends StatefulWidget {
  static const nameRoute = "/AddCategory";
  final Function(double) onBalanceUpdated;
  final Function(Category) onCategoryAdded;
  final double currentBalance;

  const AddCategory({
    super.key,
    required this.onBalanceUpdated,
    required this.onCategoryAdded,
    required this.currentBalance,
  });

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _categoryNameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          label: const Text("Back"),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitForm,
          label: const Text("Add Category"),
          icon:
              _isSubmitting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.add),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
      title: Text(
        "Add Your Category",
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Your Balance :",
                  style: GoogleFonts.roboto(color: Colors.deepPurple),
                ),
                Text(
                  "Rp. ${widget.currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: GoogleFonts.roboto(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _categoryNameController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: const Icon(
                  Icons.category,
                  color: Colors.deepPurple,
                ),
                label: const Text(
                  "Category Name",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hintText: "Enter Category Name...",
                hintStyle: const TextStyle(
                  color: Colors.deepPurple,
                  fontStyle: FontStyle.italic,
                ),
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.account_balance,
                  color: Colors.deepPurple,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(20),
                ),
                label: const Text(
                  "Category Balance",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hintText: "Enter Balance Amount...",
                hintStyle: const TextStyle(
                  color: Colors.deepPurple,
                  fontStyle: FontStyle.italic,
                ),
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Balance is required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Enter valid amount';
                }
                if (amount > widget.currentBalance) {
                  return 'Insufficient balance';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final categoryName = _categoryNameController.text;
      final categoryBalance = double.parse(_balanceController.text);

      // Create new category
      final newCategory = Category(
        name: categoryName,
        balance: categoryBalance,
      );

      // Send to API
      final apiResponse = await ApiService.createCategory(
        categoryName,
        categoryBalance.toInt(),
      );

      if (!apiResponse['success']) {
        throw Exception(apiResponse['error'] ?? 'Failed to create category');
      }

      // Update local storage
      await BalanceService.withdrawBalance(categoryBalance);
      await CategoryService.addCategory(newCategory);

      // Update UI
      widget.onBalanceUpdated(widget.currentBalance - categoryBalance);
      widget.onCategoryAdded(newCategory);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
