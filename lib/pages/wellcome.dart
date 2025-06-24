import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './sign_in.dart';

class Wellcome extends StatelessWidget {
  static const nameRoute = "/Wellcome";
  const Wellcome({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    "Wellcome",
                    style: GoogleFonts.pacifico(
                      color: Colors.white,

                      fontSize: 30,
                    ),
                  ),
                  Text(
                    "FinPocket",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "Take\nControl\nof Your\nFinances",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "FinPocket helps you manage income,expenses,\nand savings-effortlessly. Your Financial freedom\nstarts here",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 15),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Signin.nameRoute);
                },
                icon: Icon(Icons.arrow_forward_ios, color: Color(0xFF22416E)),
                iconAlignment: IconAlignment.end,
                label: Text(
                  "Get Started",
                  style: GoogleFonts.inter(
                    color: Color(0xFF22416E),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
