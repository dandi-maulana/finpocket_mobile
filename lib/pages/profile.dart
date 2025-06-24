import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './homepage.dart';
import './sign_in.dart';
import '../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './balance_service.dart';
import './add_category.dart';

class Profile extends StatefulWidget {
  static const nameRoute = "/Profile";
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  double balance = 0.0;
  String userName = 'Loading...';
  String userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBalance();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Guest';
      userEmail = prefs.getString('user_email') ?? 'No email';
    });
  }

  Future<void> _loadBalance() async {
    final currentBalance = await BalanceService.getBalance();
    setState(() {
      balance = currentBalance;
    });
  }

  Future<void> _logout() async {
    final response = await ApiService.logout();
    if (response['success']) {
      // Clear local data and navigate to login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Signin.nameRoute);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['error'] ?? 'Logout failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 380,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://picsum.photos/200"),
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userEmail,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your Balance",
                      style: GoogleFonts.roboto(
                        color: Colors.deepPurpleAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp. ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      style: GoogleFonts.roboto(
                        color: Colors.deepPurpleAccent,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _logout, // Menggunakan fungsi logout dari ApiService
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.exit_to_app),
                label: Text(
                  "Log Out",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Homepage.nameRoute);
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddCategory(
                      currentBalance: balance,
                      onBalanceUpdated: (newBalance) {
                        setState(() {
                          balance = newBalance;
                        });
                      },
                      onCategoryAdded: (newCategory) {
                        // Tidak perlu action khusus di profile
                      },
                    );
                  },
                );
              },
              child: const Icon(Icons.add, color: Colors.deepPurple, size: 30),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Profile.nameRoute);
              },
              icon: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
