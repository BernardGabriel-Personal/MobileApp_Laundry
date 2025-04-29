import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../OwnerDirectoryPage/1_owner_homepage.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  _OwnerLoginScreenState createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _loginOwner() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to the Admin Home Page if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OwnerHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e.code);
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  // Function to show error dialog with design
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF6E9D4), // Background color of the dialog
          title: Center(
            // Center the title
            child: Text(
              'Login Failed', // Title text
              style: const TextStyle(
                color: Colors.blue, // Title text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              message, // The error message content
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black, // Content text color
              ),
              textAlign: TextAlign.center, // Content centered
            ),
          ),
          actions: [
            Center(
              // Center the button
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF160EF5), // Green button color
                  foregroundColor:
                      Colors.white, // Text color on the button (white)
                ),
                child: const Text(
                  'OK', // Button text
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Button text style
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align everything to the top
                children: [
                  const SizedBox(height: 80), // Move everything upwards

                  // Spacing placeholder for the logo image (no longer directly in the column)
                  const SizedBox(
                      height:
                          115), // Adjust this to match the size of the positioned image

                  // "Login as Owner" Text
                  const Text(
                    'Login as Owner',
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

                  // Email Input
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address', // Label text
                      labelStyle: TextStyle(
                        color: Colors.grey[700], // Default label color
                        fontSize: 16, // Default label size
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Color(0xFF160EF5), // Label color when floating
                        fontSize: 16, // Make the label smaller when floating
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFFF6E9D4), // Background color BDC3C7
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                        borderSide: BorderSide.none, // No visible border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners when enabled
                        borderSide: BorderSide.none, // No visible border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners when focused
                        borderSide: BorderSide(
                          color: Color(0xFF160EF5), // Border color when focused
                          width: 2.0,
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior
                          .auto, // Let it float automatically
                    ),
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color(0xFF160EF5), // Change the cursor color
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Toggle visibility
                    decoration: InputDecoration(
                      labelText: 'Password', // Label text
                      labelStyle: TextStyle(
                        color: Colors.grey[700], // Default label color
                        fontSize: 16, // Default label size
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Color(0xFF160EF5), // Label color when floating
                        fontSize: 16, // Make the label smaller when floating
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFFF6E9D4), // Background color BDC3C7
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                        borderSide: BorderSide.none, // No visible border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners when enabled
                        borderSide: BorderSide.none, // No visible border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Rounded corners when focused
                        borderSide: BorderSide(
                          color: Color(0xFF160EF5), // Border color when focused
                          width: 2.0,
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior
                          .auto, // Let it float automatically
                      suffixIcon: IconButton(
                        // Eye icon for toggling visibility
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                    cursorColor: Color(0xFF160EF5), // Change the cursor color
                  ),

                  const SizedBox(height: 35),

                  // Login Button
                  SizedBox(
                    width: double
                        .infinity, // Set the button width to match the text fields
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginOwner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF160EF5), // Button color 04D26F
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFFECF0F1),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          5), // Adjusting to create space below the login button
                ],
              ),
            ),
          ),

          // Positioned Logo Image (FiveStarsLaundromat.png)
          Positioned(
            top: -20, // Adjust this to move the logo up or down
            left: 0,
            right:
                0, // Set both `left` and `right` to zero to center it horizontally
            child: Center(
              child: Image.asset(
                'assets/FiveStarsLaundromat.png',
                height: 250, // Adjust the size of the image
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
              color: Color(0xFFF6E9D4),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
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
                    ignoring:
                        true, // This will make the image ignore touch events
                    child: Image.asset(
                      'assets/ImageTwo.png',
                      height: 500,
                    ),
                  ),
                ),
                const Positioned(
                  left: 15,
                  bottom: 30, // Adjusted to place text higher
                  child: Text(
                    'Maximize Your\nTime,\nOptimize Your\nLaundry Business!',
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
                      fontSize: 35, // Bigger font size for emphasis
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
