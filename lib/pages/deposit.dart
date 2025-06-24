import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './balance_service.dart';
import '../services/api_services.dart';

class Deposit extends StatefulWidget {
  static const nameRoute = "/Deposit";
  const Deposit({super.key});

  @override
  State<Deposit> createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  final TextEditingController _amountController = TextEditingController();
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

  Future<void> _processDeposit() async {
    if (_amountController.text.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
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
      // Jalankan kedua operasi secara bersamaan
      // 1. Update balance lokal menggunakan BalanceService
      await BalanceService.addBalance(amount);

      // 2. Kirim deposit ke API menggunakan createTransaction
      final apiResult = await ApiService.createTransaction(
        deposit: amount.toInt(),
      );

      // Update balance dari BalanceService
      final newBalance = await BalanceService.getBalance();

      if (apiResult['success']) {
        _showSnackBar('Deposit successful!', Colors.green);
      } else {
        // Jika API gagal, beri peringatan tapi tetap lakukan deposit lokal
        _showSnackBar(
          'Deposit saved locally. Server sync may be delayed: ${apiResult['error'] ?? 'Unknown error'}',
          Colors.orange,
        );
      }

      // Tunggu sebentar untuk menampilkan snackbar
      await Future.delayed(const Duration(seconds: 1));

      // Kembali dengan balance baru
      Navigator.pop(context, newBalance);
    } catch (e) {
      // Jika ada error, tetap coba simpan lokal
      try {
        await BalanceService.addBalance(amount);
        final newBalance = await BalanceService.getBalance();

        _showSnackBar(
          'Deposit saved locally. Please check your internet connection.',
          Colors.orange,
        );

        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context, newBalance);
      } catch (localError) {
        _showSnackBar(
          'Failed to process deposit. Please try again.',
          Colors.red,
        );
      }
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
            "FinPocket Deposit",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurpleAccent, width: 2.0),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Deposit Balance",
                style: GoogleFonts.roboto(
                  color: Colors.deepPurple,
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
                    style: GoogleFonts.roboto(color: Colors.deepPurple),
                  ),
                  Text(
                    "Rp.${currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                    style: GoogleFonts.roboto(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.characters,
                enabled: !_isLoading,
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
                    Icons.account_balance_wallet_outlined,
                    color: Colors.deepPurple,
                  ),
                  label: const Text(
                    "Deposit Amount",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  hintText: "Enter Deposit Amount...",
                  hintStyle: const TextStyle(
                    color: Colors.deepPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Virtual Account Number FinPocket",
                style: GoogleFonts.roboto(color: Colors.deepPurple),
              ),
              Text(
                "882816004920",
                style: GoogleFonts.roboto(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _processDeposit,
                  label:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text("Deposit"),
                  icon:
                      _isLoading
                          ? const SizedBox.shrink()
                          : const Icon(Icons.account_balance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
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
    super.dispose();
  }
}
