import 'package:flutter/material.dart';

class CustomerSignUpScreen extends StatelessWidget {
  const CustomerSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const SizedBox(height: 115),
                  const Text(
                    'Customer Sign-Up',
                    style: TextStyle(
                      fontFamily: 'IndieFlower',
                      shadows: [
                        Shadow(
                          offset: Offset(4.0, 6.0),
                          blurRadius: 10.0,
                          color: Colors.grey,
                        ),
                      ],
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Full Name Input
                  _buildTextField(label: 'Full Name'),
                  const SizedBox(height: 16),

                  // Email Address Input
                  _buildTextField(label: 'Email Address', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  // Contact Number Input
                  _buildTextField(label: 'Contact Number', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  // Home Address Input
                  _buildTextField(label: 'Current Home Address'),
                  const SizedBox(height: 16),

                  // Password Input
                  _buildTextField(label: 'Password', obscureText: true),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Customer signed up");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF04D26F),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Positioned logo image
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/FiveStarsLaundromat.png',
                height: 250,
              ),
            ),
          ),

          // Positioned Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.grey[500],
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        floatingLabelStyle: const TextStyle(color: Colors.green, fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFBDC3C7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
      cursorColor: Colors.green,
    );
  }
}
