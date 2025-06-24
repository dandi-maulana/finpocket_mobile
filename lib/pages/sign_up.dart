import 'package:flutter/material.dart';
import './sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_services.dart';

class Signup extends StatefulWidget {
  // Changed to StatefulWidget
  static const nameRoute = "/Signup";
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await ApiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        // Registration successful, navigate to homepage
        Navigator.pushNamed(context, Signin.nameRoute);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF97B7E9),
              Color(0xFF22416E),
              Color(0xFF14304F),
              Color(0xFF111E30),
            ],
            center: Alignment.topLeft,
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign Up",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 400,
                height: 380,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.characters,
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
                            Icons.person,
                            color: Color(0xFF22416E),
                          ),
                          label: Text(
                            "Your Name",
                            style: TextStyle(
                              color: Color(0xFF22416E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          hintText: "Enter Your Name...",
                          hintStyle: TextStyle(
                            color: Color(0xFF22416E),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        textCapitalization: TextCapitalization.characters,
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
                            Icons.email,
                            color: Color(0xFF22416E),
                          ),
                          label: Text(
                            "Your Email",
                            style: TextStyle(
                              color: Color(0xFF22416E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          hintText: "Enter Your Email...",
                          hintStyle: TextStyle(
                            color: Color(0xFF22416E),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(
                          color: Color(0xFF22416E),
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF22416E),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF22416E)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(
                            "Your Password",
                            style: TextStyle(
                              color: Color(0xFF22416E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          hintText: "Enter Your Password...",
                          hintStyle: TextStyle(
                            color: Color(0xFF22416E),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF22416E),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "If You already have an account, please ",
                            style: GoogleFonts.inter(color: Color(0xFF22416E)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                Signin.nameRoute,
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.inter(
                                color: Color(0xFF22416E),
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
            ),
          ],
        ),
      ),
    );
  }
}
