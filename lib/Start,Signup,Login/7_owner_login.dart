import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../OwnerDirectoryPage/1_owner_homepage.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  _OwnerLoginScreenState createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  // ─────────────────────────── controllers ───────────────────────────
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();

  // ─────────────────────────── state flags ───────────────────────────
  bool _isPasswordVisible = false;
  bool _isLoading = false;        // ⟵ login progress indicator
  bool _isSendingMail = false;    // ⟵ registration e-mail progress

  // ─────────────────────────── login logic ───────────────────────────
  Future<void> _loginOwner() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // go to owner home on success
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_firebaseCodeToMessage(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseCodeToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  // ─────────────────────── register-owner flow ───────────────────────
  void _openRegisterDialog() {
    _registerEmailController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(builder: (_, setLocalState) {
          Future<void> _submit() async {
            final email = _registerEmailController.text.trim();

            if (email.isEmpty || !email.contains('@')) {
              _showErrorDialog('Please enter a valid e-mail address.');
              return;
            }

            setLocalState(() => _isSendingMail = true);
            final sent = await _sendRegistrationEmail(email);
            setLocalState(() => _isSendingMail = false);

            if (sent && context.mounted) {
              Navigator.pop(context); // close the dialog
              _showSuccessDialog(
                  'Registration request sent!\nPlease wait for approval, expect an email regarding your account login details.');
            }
          }

          return AlertDialog(
            backgroundColor: const Color(0xFFF6E9D4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text(
                'Register Owner',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _registerEmailController,
                  decoration: InputDecoration(
                    labelText: 'Enter your e-mail',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF160EF5),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _isSendingMail
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF160EF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<bool> _sendRegistrationEmail(String ownerEmail) async {
    const String smtpUser = 'bernardgabriel151@gmail.com';
    const String smtpPass = 'gafumrtlknkdahww';

    final smtpServer = gmail(smtpUser, smtpPass);
    final message = Message()
      ..from = Address(smtpUser, 'Five-Stars Laundry')
      ..recipients.add(smtpUser)
      ..subject = 'Five-Stars Laundry Owner Account Registration'
      ..html = '''
<html lang="">
 <div style="text-align: center;">
  <img src="https://media-hosting.imagekit.io/9b51a43beffc4f23/FiveStarsLaundromat.png?Expires=1840554596&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=cOlx1ZmmHBALGg0GLJsqmEYLxEzqIh2tZeOg6EUXGsqsCvdCeW6k4Nx0S7ggmRX19BDuODhziQ89kUozzc5~Pbzd8iEVC3jn7~a6RdE0OY-sA2A9rkhd4hERhAbG9yNsU18zYcCYTugVjsEsUR7Uu7U~SKWfOKiUBcwIbBB-td0vasLeFYNSWeZrrX-28UMmAnaOQOyin3DzI8Et0SnwFkh3H7GBpyEZM42Z0Miadn0vG22LwZJekCVD1wV~XTcU6pAKtYW8WOADo86TURiOp94yy67fijpzaqFiU0YfnO-dnQn08qNoaz3Kswu8yq4xp6elVwUzf25I8uv5CDaApg__" alt="Five-Stars Laundry Logo" width="200">
  </div>
  <body>
    <p>Hi MYThic team,</p>
    <p>Someone just requested owner access in the app.</p>
    <p><strong>E-mail address:</strong> $ownerEmail</p>
    <p>Please review and add them manually to Firebase. Do not forget to email them about their account verification/creation.</p>
    <br>
    <p>Regards,<br>Five-Stars Laundry Bot</p>
  </body>
</html>
''';


    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      _showErrorDialog('Failed to send e-mail. Please try again later.');
      return false;
    }
  }

  // ─────────────────────────── dialogs ───────────────────────────
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF6E9D4),
        title: const Center(
          child: Text(
            'Success',
            style: TextStyle(
              color: const Color(0xFF04D26F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF160EF5),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
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
              Text(
                'Login Failed',
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
                  backgroundColor: const Color(0xFF160EF5),
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

  // ─────────────────────────── ui ───────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // background gradient & main form
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const SizedBox(height: 115), // space for logo

                  const Text(
                    'Login as Owner',
                    style: TextStyle(
                      fontFamily: 'IndieFlower',
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(4, 6),
                          blurRadius: 10,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // ── e-mail ──
                  TextField(
                    controller: _emailController,
                    decoration: _decor('Email Address'),
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color(0xFF160EF5),
                  ),
                  const SizedBox(height: 16),

                  // ── password ──
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: _decor('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    cursorColor: const Color(0xFF160EF5),
                  ),
                  const SizedBox(height: 35),

                  // ── login button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF160EF5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _isLoading ? null : _loginOwner,
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(fontSize: 24, color: const Color(0xFFECF0F1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── register owner link ──
                  TextButton(
                    onPressed: _openRegisterDialog,
                    child: Text(
                      'Register as Owner',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 4.0),
                            blurRadius: 10.0,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // logo
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

          // back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: const Color(0xFFF6E9D4)),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // bottom artwork & slogan
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Positioned(
                  right: -145,
                  bottom: -170,
                  child: IgnorePointer(
                    child: Image.asset('assets/ImageTwo.png', height: 500),
                  ),
                ),
                const Positioned(
                  left: 15,
                  bottom: 30,
                  child: Text(
                    'Maximize Your\nTime,\nOptimize Your\nLaundry Business!',
                    style: TextStyle(
                      fontFamily: 'IndieFlower',
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          offset: Offset(4, 6),
                          blurRadius: 10,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // reuse the same decoration for text-fields
  InputDecoration _decor(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
    floatingLabelStyle:
    const TextStyle(color: Color(0xFF160EF5), fontSize: 16),
    filled: true,
    fillColor: const Color(0xFFF6E9D4),
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
      borderSide: const BorderSide(color: Color(0xFF160EF5), width: 2),
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );

  // ───────────────────────── dispose ─────────────────────────
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    super.dispose();
  }
}
