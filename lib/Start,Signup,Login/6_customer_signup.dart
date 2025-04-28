import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'ERROR',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF04D26F),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'SUCCESS',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF04D26F),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isValidContactNumber(String number) {
    return RegExp(r'^\d{11}$').hasMatch(number);
  }

  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true; // Start the loading spinner
    });

    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String contact = _contactController.text.trim();
    String address = _addressController.text.trim();
    String password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || contact.isEmpty || address.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false; // Stop the loading spinner
      });
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _isLoading = false; // Stop the loading spinner
      });
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    if (!_isValidContactNumber(contact)) {
      setState(() {
        _isLoading = false; // Stop the loading spinner
      });
      _showErrorDialog("Please enter a valid 11-digit contact number.");
      return;
    }

    if (password.length < 6) {
      setState(() {
        _isLoading = false; // Stop the loading spinner
      });
      _showErrorDialog("Password must be at least 6 characters long.");
      return;
    }

    // Check if email already exists in Firestore
    var emailCheck = await FirebaseFirestore.instance
        .collection('customers')
        .where('email', isEqualTo: email)
        .get();

    if (emailCheck.docs.isNotEmpty) {
      setState(() {
        _isLoading = false; // Stop the loading spinner
      });
      _showErrorDialog("An account with this email already exists.");
      return;
    }

    // Simulate a delay for signing up (this is where your firebase logic would go)
    await FirebaseFirestore.instance.collection('customers').add({
      'fullName': fullName,
      'email': email,
      'contact': contact,
      'address': address,
      'password': password, // You should hash passwords in a real app for security
    });

    setState(() {
      _isLoading = false; // Stop the loading spinner
    });

    _showSuccessDialog("Customer signed up successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow the screen to resize when keyboard shows up
      body: Scrollbar( // Wrap the SingleChildScrollView with Scrollbar
        child: SingleChildScrollView( // Wrap the entire body in SingleChildScrollView
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
                      _buildTextField(label: 'Full Name', controller: _fullNameController),
                      const SizedBox(height: 16),

                      // Email Address Input
                      _buildTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Contact Number Input
                      _buildTextField(
                        label: 'Contact Number',
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Current Home Address Input
                      _buildTextField(
                        label: 'Current Home Address',
                        controller: _addressController,
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04D26F),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Color(0xFF04D26F),
                          )
                              : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
                  child: Image.asset(
                    'assets/FiveStarsLaundromat.png',
                    height: 250,
                  ),
                ),
              ),

              // Positioned Back Button (top-left corner)
              Positioned(
                top: MediaQuery.of(context).padding.top + 15, // Add padding for safe area
                left: 15,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.grey[500],
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
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
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[500],
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
      cursorColor: Colors.green,
    );
  }
}
