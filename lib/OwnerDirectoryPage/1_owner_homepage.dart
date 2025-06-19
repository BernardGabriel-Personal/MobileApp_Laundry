import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '2_employee_management.dart';
import '3_customer_management.dart';
import '4_owner_profilePage.dart';
import '5_rider_managementPage.dart';
import 'package:intl/intl.dart';
import '../Start,Signup,Login/2_welcome_page.dart';
// ignore_for_file: deprecated_member_use

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  _OwnerHomePageState createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  String currentTime = "";
  String ownerName = "[Owner]";

  @override
  void initState() {
    super.initState();
    currentTime = _getCurrentTime();
    _fetchOwnerName(); // Fetch name on init

    // Update time every minute
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        currentTime = _getCurrentTime();
      });
    });
  }

  // Format the current time
  String _getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('h:mm a | MMMM d, yyyy').format(now);
  }

  // Fetch owner fullName from Firestore
  Future<void> _fetchOwnerName() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('owner')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          ownerName = data['fullName'] ?? "Owner";
        });
      }
    } catch (e) {
      print('Error fetching owner name: $e');
    }
  }

  // Logout confirmation dialog
  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6E9D4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: const Color(0xFFE57373), size: 28),
            SizedBox(width: 10),
            Text('Are you leaving?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You can always log back in at any time.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showLogoutConfirmation(context),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // UPPER PART
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFF170CFE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.account_circle, size: 60, color: const Color(0xFF04D26F)),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Five-Stars Laundry',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF0F0F0),
                                ),
                              ),
                              Text(
                                '$ownerName',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF0F0F0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        currentTime,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF0F0F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MID PART
              Transform.translate(
                offset: Offset(0, 20),
                child: Container(
                  color: const Color(0xFFF6E9D4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Employee Management
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmployeeManagementPage()),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            width: 310,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/EmployeeManagementIcon.png',
                                    width: 400,
                                    height: 150,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Employee Management',
                                    style: TextStyle(
                                      color: const Color(0xFF170CFE),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      height: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Customer Management
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerManagementPage()),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            width: 310,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/CustomerManagementIcon.png',
                                    width: 400,
                                    height: 150,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Customer Management',
                                    style: TextStyle(
                                      color: const Color(0xFF04D26F),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      height: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Rider Management
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RiderManagementPage()),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            width: 310,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/RiderManagementIcon.png',
                                    width: 400,
                                    height: 150,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Rider Management',
                                    style: TextStyle(
                                      color: const Color(0xFFEE7600), // Orange for distinction
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      height: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),

              // BOTTOM PART
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF04D26F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),

        // BOTTOM NAVIGATION BAR
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color(0xFF170CFE),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white, size: 30),
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () {
                  // Already on Home
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const OwnerProfilePage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        backgroundColor: const Color(0xFFF6E9D4),
      ),
    );
  }
}
