import 'package:flutter/material.dart';
import './withdraw.dart';
import './deposit.dart';
import 'package:google_fonts/google_fonts.dart';
import './profile.dart';
import './add_category.dart';
import './pay.dart';
import 'balance_service.dart';
import 'category_service.dart';
import 'category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  static const nameRoute = "/Homepage";
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  double balance = 0.0;
  List<Category> categories = [];
  String userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Guest';
    });
  }

  Future<void> _loadData() async {
    final currentBalance = await BalanceService.getBalance();
    final loadedCategories = await CategoryService.getCategories();
    setState(() {
      balance = currentBalance;
      categories = loadedCategories;
    });
  }

  Future<void> _deleteCategory(int index, double categoryBalance) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: const Text(
              'Are you sure you want to delete this category? The balance will be returned to your main account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete == true) {
      // Delete the category
      await CategoryService.deleteCategory(index);

      // Return balance to main account
      await BalanceService.addBalance(categoryBalance);

      // Reload data
      final currentBalance = await BalanceService.getBalance();
      final loadedCategories = await CategoryService.getCategories();

      setState(() {
        balance = currentBalance;
        categories = loadedCategories;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 380,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        "FinPocket",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://picsum.photos/200",
                        ),
                      ),
                      const SizedBox(width: 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.roboto(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Your Balance :",
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Rp.${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                            style: GoogleFonts.roboto(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Pay.nameRoute);
                        },
                        style: ElevatedButton.styleFrom(),
                        icon: const Icon(Icons.payment),
                        label: Text(
                          "Pay",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final newBalance = await Navigator.pushNamed(
                            context,
                            Withdraw.nameRoute,
                            arguments: balance,
                          );
                          if (newBalance != null) {
                            setState(() {
                              balance = newBalance as double;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(),
                        icon: const Icon(Icons.account_balance_wallet),
                        label: Text(
                          "Withdraw",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final newBalance = await Navigator.pushNamed(
                            context,
                            Deposit.nameRoute,
                            arguments: balance,
                          );
                          if (newBalance != null) {
                            setState(() {
                              balance = newBalance as double;
                            });
                          }
                        },
                        icon: const Icon(Icons.account_balance),
                        label: Text(
                          "Deposit",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Your Categories",
            style: GoogleFonts.roboto(
              fontSize: 20,
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Dismissible(
                  key: Key(category.name + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Category'),
                            content: const Text(
                              'Are you sure you want to delete this category? The balance will be returned to your main account.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  onDismissed: (direction) async {
                    // Delete the category and return balance
                    await _deleteCategory(index, category.balance);
                  },
                  child: Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name),
                          const SizedBox(height: 10),
                          Text(
                            "Rp.${category.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          ),
                        ],
                      ),
                      leading: Icon(
                        Icons.category,
                        color: Colors.deepPurpleAccent,
                        size: 40,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deleteCategory(index, category.balance);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
              onPressed: () {},
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
                        setState(() {
                          categories.add(newCategory);
                        });
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
