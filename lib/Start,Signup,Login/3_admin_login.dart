import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '5_admin_signup.dart';
import '../AdminDirectoryPage/1_admin_homepage.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Hashing function using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _loginAdmin() async {
    String employeeId = _idController.text.trim();
    String password = _passwordController.text.trim();

    if (employeeId.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both Employee ID and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot adminQuery = await FirebaseFirestore.instance
          .collection('approved_admin')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        DocumentSnapshot adminDoc = adminQuery.docs.first;
        String storedPassword = adminDoc['password'];
        String hashedInputPassword = hashPassword(password);

        if (storedPassword == hashedInputPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(
                fullName: adminDoc['fullName'],
                branch: adminDoc['branch'],
                employeeId: adminDoc['employeeId'],
                contact: adminDoc['contact'],
                email: adminDoc['email'],
              ),
            ),
          );
        } else {
          _showErrorDialog('Invalid password.');
        }
      } else {
        _showErrorDialog('Employee ID not found.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred during login. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                Icons.error_outline,
                color: const Color(0xFFE57373),
                size: 50,
              ),
              const SizedBox(height: 8),
              const Text(
                'Login Failed',
                style: TextStyle(
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                    'Login as Employee',
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFBDC3C7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                        const BorderSide(color: Colors.green, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFBDC3C7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                        const BorderSide(color: Colors.green, width: 2.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    cursorColor: Colors.green,
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginAdmin,
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 24, color: Color(0xFFECF0F1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminSignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Create an Account',
                      style: TextStyle(
                        color: const Color(0xFF04D26F),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(1.0, 4.0),
                            blurRadius: 10.0,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ],
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Positioned(
                  right: -145,
                  bottom: -170,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Image.asset(
                      'assets/ImageTwo.png',
                      height: 500,
                    ),
                  ),
                ),
                const Positioned(
                  left: 25,
                  bottom: 20,
                  child: Text(
                    'Simplify\nInventory Control\nand Pricing with\nEase!',
                    style: TextStyle(
                      fontFamily: 'IndieFlower',
                      shadows: [
                        Shadow(
                          offset: Offset(4.0, 6.0),
                          blurRadius: 10.0,
                          color: Colors.grey,
                        ),
                      ],
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
