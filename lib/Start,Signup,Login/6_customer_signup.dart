import 'dart:convert'; // For utf8.encode
import 'package:crypto/crypto.dart'; // For SHA-256 hash
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Password hashing using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Icon(Icons.error_outline, color: const Color(0xFFE57373), size: 50),
            const SizedBox(height: 8),
            const Text('ERROR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF04D26F),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Icon(Icons.check_circle, color: const Color(0xFF04D26F), size: 50),
            const SizedBox(height: 8),
            const Text('Sign-up successful', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF04D26F),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  bool _isValidContactNumber(String number) => RegExp(r'^\d{11}$').hasMatch(number);

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String contact = _contactController.text.trim();
    String address = _addressController.text.trim();
    String password = _passwordController.text;

    if ([fullName, email, contact, address, password].any((field) => field.isEmpty)) {
      setState(() => _isLoading = false);
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _isLoading = false);
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    if (!_isValidContactNumber(contact)) {
      setState(() => _isLoading = false);
      _showErrorDialog("Please enter a valid 11-digit contact number.");
      return;
    }

    if (password.length < 6) {
      setState(() => _isLoading = false);
      _showErrorDialog("Password must be at least 6 characters long.");
      return;
    }

    final emailExists = await FirebaseFirestore.instance
        .collection('customers')
        .where('email', isEqualTo: email)
        .get();

    if (emailExists.docs.isNotEmpty) {
      setState(() => _isLoading = false);
      _showErrorDialog("An account with this email already exists.");
      return;
    }

    final contactExists = await FirebaseFirestore.instance
        .collection('customers')
        .where('contact', isEqualTo: contact)
        .get();

    if (contactExists.docs.isNotEmpty) {
      setState(() => _isLoading = false);
      _showErrorDialog("A customer with this phone number already exists.");
      return;
    }

    final hashedPassword = _hashPassword(password);

    await FirebaseFirestore.instance.collection('customers').add({
      'fullName': fullName,
      'email': email,
      'contact': contact,
      'address': address,
      'password': hashedPassword,
    });

    _clearTextFields();
    setState(() => _isLoading = false);
    _showSuccessDialog("Customer signed up successfully! You can now log-in");
  }

  void _clearTextFields() {
    _fullNameController.clear();
    _emailController.clear();
    _contactController.clear();
    _addressController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Stack(
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
                    children: [
                      const SizedBox(height: 80),
                      const SizedBox(height: 115),
                      const Text(
                        'Customer Sign-Up',
                        style: TextStyle(
                          fontFamily: 'IndieFlower',
                          shadows: [Shadow(offset: Offset(4.0, 6.0), blurRadius: 10.0, color: Colors.grey)],
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
                      _buildTextField(label: 'Password', controller: _passwordController, isPassword: true),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04D26F),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: const Color(0xFF04D26F))
                              : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset('assets/FiveStarsLaundromat.png', height: 250),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 15,
                left: 15,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.grey[500],
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        floatingLabelStyle: const TextStyle(color: Colors.green, fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFBDC3C7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.green, width: 2.0)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
      ),
      cursorColor: Colors.green,
    );
  }
}
