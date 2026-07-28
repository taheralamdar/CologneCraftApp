import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'webview_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  "assets/logo.png",
                  width: 220,
                ),

                const SizedBox(height: 40),

                Text(
                  "Luxury Inspired Perfumes",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WebViewScreen(
                            url:
                            "https://www.colognecraft.com/account/login",
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WebViewScreen(
                            url:
                            "https://www.colognecraft.com/account/register",
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WebViewScreen(
                          url: "https://www.colognecraft.com",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue as Guest",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}