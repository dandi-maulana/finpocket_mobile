import 'package:flutter/material.dart';
import './pages/homepage.dart';
import './pages/withdraw.dart';
import './pages/deposit.dart';
import './pages/profile.dart';
import './pages/add_category.dart';
import './pages/wellcome.dart';
import './pages/sign_in.dart';
import './pages/sign_up.dart';
import './pages/pay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/balance_service.dart';
import './pages/category_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Initialize Services
    await _initializeServices(prefs);

    runApp(const FinPocket());
  } catch (e) {
    // Handle initialization errors
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize app: $e')),
        ),
      ),
    );
  }
}

Future<void> _initializeServices(SharedPreferences prefs) async {
  BalanceService.init(prefs);
  CategoryService.init(prefs);

  // Initialize with default balance if not exists
  final currentBalance = await BalanceService.getBalance();
  if (currentBalance == 0.0) {
    await BalanceService.setBalance(0.0);
  }
}

class FinPocket extends StatelessWidget {
  const FinPocket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinPocket',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Wellcome.nameRoute,
      routes: {
        Homepage.nameRoute: (context) => const Homepage(),
        Withdraw.nameRoute: (context) => const Withdraw(),
        Profile.nameRoute: (context) => const Profile(),
        Deposit.nameRoute: (context) => const Deposit(),
        Wellcome.nameRoute: (context) => const Wellcome(),
        Signin.nameRoute: (context) => const Signin(),
        Signup.nameRoute: (context) => const Signup(),
        Pay.nameRoute: (context) => const Pay(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AddCategory.nameRoute) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) => AddCategory(
                  currentBalance: args['currentBalance'],
                  onBalanceUpdated: args['onBalanceUpdated'],
                  onCategoryAdded: args['onCategoryAdded'],
                ),
          );
        }
        return null;
      },
    );
  }
}
