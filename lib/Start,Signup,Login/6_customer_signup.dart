import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _signUp() async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _contactController.text.trim(),
        'address': _addressController.text.trim(),
        'role': 'customer',
      });

      // Navigate to customer homepage
      Navigator.pushNamed(context, '/customer-home');
    } catch (e) {
      print('Sign up error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed. Please try again.')),
      );
    }
  }

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

                  _buildTextField(label: 'Full Name', controller: _fullNameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Email Address', controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Contact Number', controller: _contactController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Current Home Address', controller: _addressController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Password', controller: _passwordController, obscureText: true),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signUp,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
      cursorColor: Colors.green,
    );
  }
}
