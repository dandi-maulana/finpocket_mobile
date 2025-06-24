import 'package:shared_preferences/shared_preferences.dart';

class BalanceService {
  static const String _balanceKey = 'user_balance';
  static late SharedPreferences _prefs;

  // Initialize with pre-instantiated SharedPreferences
  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static Future<double> getBalance() async {
    return _prefs.getDouble(_balanceKey) ?? 0.0; // Default value
  }

  static Future<void> setBalance(double newBalance) async {
    await _prefs.setDouble(_balanceKey, newBalance);
  }

  static Future<void> addBalance(double amount) async {
    final currentBalance = await getBalance();
    await setBalance(currentBalance + amount);
  }

  static Future<bool> withdrawBalance(double amount) async {
    final currentBalance = await getBalance();
    if (amount > currentBalance) {
      return false; // Insufficient balance
    }
    await setBalance(currentBalance - amount);
    return true; // Withdrawal successful
  }

  // Optional: Clear balance (for logout or testing)
  static Future<void> clearBalance() async {
    await _prefs.remove(_balanceKey);
  }
}
