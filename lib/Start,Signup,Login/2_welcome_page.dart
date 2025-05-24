import 'package:flutter/material.dart';
import 'dart:math';
import '3_admin_login.dart';
import '4_customer_login.dart';
import '7_owner_login.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Future<bool> hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _checkInternetAndShowDialog();
  }

  void _checkInternetAndShowDialog() async {
    bool hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      _showNoInternetDialog();
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        _showWelcomeDialog();
      });
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AnimatedDialog();
      },
    );
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        elevation: 16.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'No Internet Connection!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.green, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    _checkInternetAndShowDialog(); // Retry checking
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ClipPath(
                clipper: WaveClipper(_animationController.value),
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF68D391), Color(0xFFECF0F1)],
                    ),
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              SizedBox(
                width: 190,
                height: 190,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: GradientRotation(_animationController.value * 2 * pi),
                    ).createShader(bounds);
                  },
                  child: Image.asset(
                    'assets/FiveStarsLaundromat.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Effortless Laundry,\nFive-Star Results!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'IndieFlower',
                  shadows: [
                    Shadow(
                      offset: Offset(6.0, 8.0),
                      blurRadius: 10.0,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Flexible(
                child: Image.asset(
                  'assets/ImageOne.png',
                  width: 400,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(context, 'EMPLOYEE', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                    );
                  }),
                  _buildButton(context, 'CUSTOMER', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              // Login as Owner button added below EMPLOYEE and CUSTOMER buttons
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OwnerLoginScreen()),
                  );
                },
                child: Text(
                  'LOGIN AS OWNER',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF160EF5),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 4.0),
                        blurRadius: 10.0,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF04D26F),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(
            color: Color(0xFF2D3436),
            width: 2,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 10.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  WaveClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);
    var firstControlPoint = Offset(size.width / 4, size.height - 50 + sin(animationValue * 2 * pi) * 20);
    var firstEndPoint = Offset(size.width / 2, size.height - 30 + sin(animationValue * 2 * pi) * 20);
    var secondControlPoint = Offset(3 * size.width / 4, size.height - 10 + sin(animationValue * 2 * pi) * 20);
    var secondEndPoint = Offset(size.width, size.height - 50 + sin(animationValue * 2 * pi) * 20);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({super.key});

  @override
  _AnimatedDialogState createState() => _AnimatedDialogState();
}
class _AnimatedDialogState extends State<AnimatedDialog> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void _fadeOutAndClose() {
    setState(() {
      _opacity = 0.0;
    });

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      elevation: 16.0,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: SingleChildScrollView( // Wrap with scroll view
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Welcome to Five-Stars Laundry!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You are using the first version of our laundry app (v1.0.0), developed by MYThic for Five-Stars Laundromat.',
                  style: TextStyle(
                    fontSize: 16.0,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We collect account info, order data, and limited device details to deliver our laundry services efficiently. '
                      'Your data is shared only with authorized staff and payment processors, and is never sold. '
                      'You have the right to access, correct, or delete your information under the Data Privacy Act of 2012.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'By using this app, you agree to follow branch-specific service availability and dynamic pricing. '
                      'Services are only available within Dasmariñas, Cavite, Philippines and on Android devices. '
                      'Misuse, fraud, or policy violations may lead to account suspension/deletion.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you have any questions, concerns, requests or feedback, feel free to email us at:',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'bernardgabriel151@gmail.com\nmiguel23manuntag@gmail.com\ntomtan096@gmail.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    onPressed: _fadeOutAndClose,
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
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
