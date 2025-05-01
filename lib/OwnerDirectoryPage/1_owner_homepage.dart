import 'package:flutter/material.dart';
import 'dart:async';
import '2_employee_management.dart';
import 'package:intl/intl.dart'; //package for date/time formatting

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  _OwnerHomePageState createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  String currentTime = ""; // To store the current time

  @override
  void initState() {
    super.initState();
    currentTime = _getCurrentTime();

    // Update the time every minute
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        currentTime = _getCurrentTime();
      });
    });
  }

  // Function to get current time and date (formatted)
  String _getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('h:mm a | MMMM d, yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // UPPER PART (color #F9BE7C)


            Container(
              height: MediaQuery.of(context).size.height *
                  0.3, // 30% of the screen height
              decoration: BoxDecoration(
                color: const Color(0xFF170CFE), // Background color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Centers vertically
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // Centers horizontally
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          // Size of the avatar
                          backgroundColor: Colors.grey[200],
                          // Avatar background color
                          child: Icon(
                            Icons.account_circle,
                            size: 60,
                            color: const Color(0xFF04D26F), // Icon color
                          ),
                        ),
                        SizedBox(width: 20),
                        // Adds space between the avatar and the text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Five-Stars Laundry',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF0F0F0)),
                            ),
                            Text(
                              'Welcome [Owner]',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF0F0F0)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Display the updated time and date here
                    Text(
                      currentTime,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF0F0F0)),
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
                // color to match screen BG color
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal scrolling
                  child: Row(
                    children: [
                      // First Rectangle
                      // First Rectangle
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
                            color: Color(0xFFD9D9D9),
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


                      // Second Rectangle
                      Container(
                        margin: const EdgeInsets.all(12),
                        width: 310,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          // Rectangle background color
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // BOTTOM PART (color #F0F0F0)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
              color: const Color(0xFF04D26F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
            )
              )
    )
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6E9D4), // Background color
    );
  }
}
