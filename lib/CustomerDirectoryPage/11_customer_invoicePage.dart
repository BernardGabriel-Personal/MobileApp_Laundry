import 'package:flutter/material.dart';
import '../Start,Signup,Login/2_welcome_page.dart';   // logout → HomeScreen
import '1_customer_homepage.dart';
import '8_customer_profilePage.dart';
import '7_customer_cartPage.dart';
import '10_customer_schedulesPage.dart';

class customerInvoicePage extends StatefulWidget {
  final String fullName;
  final String address;
  final String email;
  final String contact;

  const customerInvoicePage({
    Key? key,
    required this.fullName,
    required this.address,
    required this.email,
    required this.contact,
  }) : super(key: key);

  @override
  State<customerInvoicePage> createState() => _customerInvoicePageState();
}

class _customerInvoicePageState extends State<customerInvoicePage> {
  Future<bool> _confirmLogout(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => _styledAlert(
        icon: Icons.error_outline,
        iconColor: const Color(0xFFE57373),
        title: 'Are you leaving?',
        message:
        'Are you sure you want to log out? You can always log back in at any time.',
        okLabel: 'Logout',
        cancelLabel: 'Cancel',
      ),
    );
    return res == true;
  }

  AlertDialog _styledAlert({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String okLabel,
    required String cancelLabel,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFFD9D9D9),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 18)),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 14)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: iconColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(okLabel),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && await _confirmLogout(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECF0F3),
        body: SafeArea(
          child: Column(
            children: [
              // ─── HEADER ────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: const BoxDecoration(
                  color: const Color(0xFF04D26F),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.receipt_long, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Your Invoices',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // ─── PLACEHOLDER (replace with actual invoice list later) ─────
              Expanded(
                child: Center(
                  child: Text(
                    'No invoices yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── BOTTOM NAVIGATION BAR ────────────────────────────────────────
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF04D26F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // Invoice tab
          onTap: (i) {
            switch (i) {
              case 0: // Cart
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CartPage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 2: // Home
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CustomerHomePage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 3: // Schedules
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => scheduledOrderPage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
              case 4: // Profile
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CustomerProfilePage(
                      fullName: widget.fullName,
                      address: widget.address,
                      contact: widget.contact,
                      email: widget.email,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Invoice'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), label: 'Schedules'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
