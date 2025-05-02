import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSignUpScreen extends StatefulWidget {
  const AdminSignUpScreen({super.key});

  @override
  _AdminSignUpScreenState createState() => _AdminSignUpScreenState();
}

class _AdminSignUpScreenState extends State<AdminSignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _employeeIdController =
      TextEditingController(); // Employee ID Controller
  String? _selectedBranch;
  bool _isLoading = false; // Track loading state

  // Function to handle sign-up
  Future<void> _signUpAdmin() async {
    setState(() {
      _isLoading = true; // Set loading state to true when the sign-up starts
    });
    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String contact = _contactController.text.trim();
    final String employeeIdText = _employeeIdController.text.trim();
    final int? employeeId =
        int.tryParse(employeeIdText); // Try to parse employee ID as integer

    if (fullName.isEmpty ||
        email.isEmpty ||
        contact.isEmpty ||
        _selectedBranch == null ||
        employeeId == null) {
      _showErrorDialog('Please fill in all fields.');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address.');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      return;
    }

    if (!_isValidContactNumber(contact)) {
      _showErrorDialog('Please enter a valid 11-digit contact number.');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      return;
    }

    try {
      // Check if email already exists in Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _showErrorDialog('An employee with this email already exists.');
        setState(() {
          _isLoading = false; // Stop loading on error
        });
        return;
      }

      // Check if contact number already exists in Firestore
      final phoneSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('contact', isEqualTo: contact)
          .get();

      if (phoneSnapshot.docs.isNotEmpty) {
        _showErrorDialog('An employee with this phone number already exists.');
        setState(() {
          _isLoading = false; // Stop loading on error
        });
        return;
      }

      // Check if employeeId already exists in Firestore
      final employeeIdSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      if (employeeIdSnapshot.docs.isNotEmpty) {
        _showErrorDialog('An employee with this Employee ID already exists.');
        setState(() {
          _isLoading = false; // Stop loading on error
        });
        return;
      }

      // Add user data to Firestore
      await FirebaseFirestore.instance.collection('admin').add({
        'fullName': fullName,
        'email': email,
        'contact': contact,
        'branch': _selectedBranch,
        'employeeId': employeeId, // Store Employee ID as integer
        'createdAt': FieldValue.serverTimestamp(),
      });

      // After sign-up, show a success message
      _showSuccessDialog(
          'Your account is being verified. Expect an email for further confirmation. Thanks for your patience.');
      // Clear the text fields after success
      _clearTextFields();
      setState(() {
        _isLoading = false; // Stop loading on success
      });
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  // Function to clear all text fields after successful sign-up
  void _clearTextFields() {
    _fullNameController.clear();
    _emailController.clear();
    _contactController.clear();
    _employeeIdController.clear();
    setState(() {
      _selectedBranch = null;
    });
  }

  // Helper function to validate email format
  bool _isValidEmail(String email) {
    final RegExp emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  // Helper function to validate contact number (11 digits)
  bool _isValidContactNumber(String contact) {
    final RegExp contactRegExp = RegExp(r'^\d{11}$');
    return contactRegExp.hasMatch(contact);
  }

  // Helper function to show error dialog
  // Function to show error dialog with design
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline, // Exclamation icon
                color: const Color(0xFFE57373),
                size: 50,
              ),
              const SizedBox(height: 8),
              Text(
                'ERROR',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF04D26F),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper function to show success dialog
  // Function to show success dialog with design
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF04D26F),
                size: 50,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign-up successful',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF04D26F),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allow the screen to resize when keyboard shows up
      body: Scrollbar(
        // Wrap the SingleChildScrollView with Scrollbar
        child: SingleChildScrollView(
          // Wrap the entire body in SingleChildScrollView
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
                        'Employee Sign-Up',
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
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.green, // Label color when floating
                            fontSize:
                                16, // Make the label smaller when floating
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        cursorColor:
                            Colors.green, // Set the cursor color to green
                      ),
                      const SizedBox(height: 16),

                      // Employee ID Input
                      TextField(
                        controller: _employeeIdController,
                        decoration: InputDecoration(
                          labelText: 'Employee ID',
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.green, // Label color when floating
                            fontSize:
                                16, // Make the label smaller when floating
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType:
                            TextInputType.number, // Set to number keyboard
                        cursorColor:
                            Colors.green, // Set the cursor color to green
                      ),
                      const SizedBox(height: 16),

                      // Email Address Input
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.green, // Label color when floating
                            fontSize:
                                16, // Make the label smaller when floating
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor:
                            Colors.green, // Set the cursor color to green
                      ),
                      const SizedBox(height: 16),

                      // Contact Number Input
                      TextField(
                        controller: _contactController,
                        decoration: InputDecoration(
                          labelText: 'Contact Number [11 digits]',
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.green, // Label color when floating
                            fontSize:
                                16, // Make the label smaller when floating
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        cursorColor:
                            Colors.green, // Set the cursor color to green
                      ),
                      const SizedBox(height: 16),

                      // Select a Branch Input
                      DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: InputDecoration(
                          labelText: 'Select a Branch',
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                          ),
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
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: <String>[
                          'Area C',
                          'Santa Fe',
                          'Area E',
                          'Santa Cristina'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBranch = newValue;
                          });
                        },
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Color(0xFFBDC3C7),
                        elevation: 8,
                        iconEnabledColor: Colors.green,
                      ),

                      const SizedBox(height: 16),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUpAdmin,
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
                      SizedBox(height: 10),
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
                top: MediaQuery.of(context).padding.top +
                    15, // Add padding for safe area
                left: 15,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.grey[500],
                  onPressed: () {
                    Navigator.pop(
                        context); // Navigate back to the previous screen
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
