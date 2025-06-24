import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'balance_service.dart';
import 'category_service.dart';
import 'category_model.dart';

class Pay extends StatefulWidget {
  static const nameRoute = "/Pay";
  const Pay({super.key});

  @override
  State<Pay> createState() => _PayState();
}

class _PayState extends State<Pay> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  List<Category> _categories = [];
  Category? _selectedCategory;
  double _mainBalance = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await CategoryService.getCategories();
    final balance = await BalanceService.getBalance();
    setState(() {
      _categories = categories;
      _mainBalance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(50, 50),
        child: AppBar(
          foregroundColor: Colors.white,
          title: Text(
            "FinPocket Pay",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF22416E),
        ),
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF22416E), width: 2.0),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Pay Balance",
                    style: GoogleFonts.roboto(
                      color: Color(0xFF22416E),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Your Balance :",
                        style: GoogleFonts.roboto(color: Color(0xFF22416E)),
                      ),
                      FittedBox(
                        child: Text(
                          "Rp. ${_mainBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          style: GoogleFonts.roboto(
                            color: Color(0xFF22416E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonHideUnderline(
                    child: DropdownButtonFormField2<Category>(
                      isExpanded: true,
                      hint: Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF22416E),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      items:
                          _categories
                              .map(
                                (category) => DropdownMenuItem<Category>(
                                  value: category,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF22416E),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      FittedBox(
                                        child: Text(
                                          "Rp. ${category.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF22416E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      value: _selectedCategory,
                      onChanged: (Category? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF22416E),
                            width: 1.0,
                          ),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        offset: const Offset(0, -10),
                        elevation: 1,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 60,
                        padding: EdgeInsets.only(left: 16, right: 16),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF22416E),
                          size: 30,
                        ),
                        iconEnabledColor: Color(0xFF22416E),
                        iconDisabledColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Color(0xFF22416E),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF22416E)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF22416E),
                      ),
                      label: Text(
                        "Payment Amount",
                        style: TextStyle(
                          color: Color(0xFF22416E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      hintText: "Enter payment amount...",
                      hintStyle: TextStyle(
                        color: Color(0xFF22416E),
                        fontStyle: FontStyle.italic,
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter valid amount';
                      }
                      if (_selectedCategory == null) {
                        return 'Please select category first';
                      }
                      if (amount > _selectedCategory!.balance) {
                        return 'Amount exceeds category balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Color(0xFF22416E),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_balance_outlined,
                        color: Color(0xFF22416E),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF22416E)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: Text(
                        "Account Number",
                        style: TextStyle(
                          color: Color(0xFF22416E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      hintText: "Enter account number...",
                      hintStyle: TextStyle(
                        color: Color(0xFF22416E),
                        fontStyle: FontStyle.italic,
                      ),
                      errorStyle: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter account number';
                      }
                      if (value.length < 8) {
                        return 'Account number too short';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _processPayment,
                      label: Text(_isSubmitting ? "Processing..." : "Pay"),
                      icon:
                          _isSubmitting
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Icon(Icons.payment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF22416E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);
      final category = _selectedCategory!;

      // Log the account number (to avoid unused variable warning)
      debugPrint('Payment to account: ${_accountController.text}');

      // Update category balance
      final updatedCategory = Category(
        name: category.name,
        balance: category.balance - amount,
      );

      // Update in storage
      await CategoryService.updateCategory(
        _categories.indexOf(category),
        updatedCategory,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment of Rp. ${amount.toStringAsFixed(0)} to account ${_accountController.text} successful',
          ),
          backgroundColor: Color(0xFF22416E),
        ),
      );

      // Refresh data
      await _loadData();
      _amountController.clear();
      _accountController.clear();
      setState(() => _selectedCategory = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }
}
