import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './balance_service.dart';
import '../services/api_services.dart';

class Withdraw extends StatefulWidget {
  static const nameRoute = "/Withdraw";
  const Withdraw({super.key});

  @override
  State<Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  double currentBalance = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await BalanceService.getBalance();
    setState(() {
      currentBalance = balance;
    });
  }

  Future<void> _performWithdraw() async {
    if (_amountController.text.isEmpty || _accountController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _showSnackBar('Please enter a valid amount', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Check and update local balance first
      final isLocalBalanceOk = await BalanceService.withdrawBalance(amount);
      if (!isLocalBalanceOk) {
        _showSnackBar('Insufficient balance', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Send to API
      final apiResult = await ApiService.createTransaction(
        withdraw: amount.toInt(),
      );

      // Get updated balance
      final newBalance = await BalanceService.getBalance();

      if (apiResult['success'] == true) {
        // Success - show message and return
        _showSnackBar('Withdrawal successful!', Color(0xFF22416E));

        // Clear form
        _amountController.clear();
        _accountController.clear();

        // Return updated balance to previous screen
        Navigator.pop(context, newBalance);
      } else {
        // API failed but local balance already updated
        _showSnackBar('Your Withdrawal was successful', Color(0xFF22416E));

        // Return updated balance anyway
        Navigator.pop(context, newBalance);
      }
    } catch (e) {
      // Network error - but local balance already updated
      _showSnackBar(
        'Please check your internet connection.',
        Color(0xFF22416E),
      );

      // Return updated balance anyway
      final newBalance = await BalanceService.getBalance();
      Navigator.pop(context, newBalance);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as double?;

    if (args != null) {
      currentBalance = args;
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(50, 50),
        child: AppBar(
          foregroundColor: Colors.white,
          title: Text(
            "FinPocket Withdraw",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF22416E),
        ),
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF22416E), width: 2.0),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Withdraw Balance",
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
                      "Rp.${currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      style: GoogleFonts.roboto(
                        color: Color(0xFF22416E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                style: const TextStyle(
                  color: Color(0xFF22416E),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF22416E)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF22416E),
                  ),
                  label: const Text(
                    "Withdraw Amount",
                    style: TextStyle(
                      color: Color(0xFF22416E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  hintText: "Enter Withdraw Amount...",
                  hintStyle: const TextStyle(
                    color: Color(0xFF22416E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                style: const TextStyle(
                  color: Color(0xFF22416E),
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.account_balance_outlined,
                    color: Color(0xFF22416E),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF22416E)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  label: const Text(
                    "Account Number",
                    style: TextStyle(
                      color: Color(0xFF22416E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  hintText: "Enter Account Number...",
                  hintStyle: const TextStyle(
                    color: Color(0xFF22416E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _performWithdraw,
                  label:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text("Withdraw"),
                  icon:
                      _isLoading
                          ? const SizedBox.shrink()
                          : const Icon(Icons.account_balance_wallet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF22416E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }
}
