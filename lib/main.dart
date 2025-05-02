import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'Start,Signup,Login/1_splash_screen.dart';
import 'Start,Signup,Login/2_welcome_page.dart';
// import 'AdminDirectoryPage/1_admin_homepage.dart'; // Admin home page
import 'Start,Signup,Login/3_admin_login.dart'; // Admin login screen
import 'Start,Signup,Login/5_admin_signup.dart'; // Admin sign up screen
import 'CustomerDirectoryPage/1_customer_homepage.dart'; // Customer home page
import 'Start,Signup,Login/4_customer_login.dart'; // Customer login screen
import 'Start,Signup,Login/6_customer_signup.dart'; // Customer sign up screen
import '../OwnerDirectoryPage/1_owner_homepage.dart'; // Owner home page
import 'Start,Signup,Login/7_owner_login.dart'; // Owner login screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Five Stars Laundry',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        // '/admin-home': (context) => const AdminHomePage(),  // Admin home after successful login
        '/admin-signup': (context) => const AdminSignUpScreen(),  // Admin sign-up screen
        '/customer-login': (context) => const CustomerLoginScreen(), // Customer login
        '/customer-home': (context) => const CustomerHomePage(), // Customer home after successful login
        '/customer-signup': (context) => const CustomerSignUpScreen(), // Customer sign-up screen
        '/owner-login': (context) => const OwnerLoginScreen(), // Owner login screen
        '/owner-home': (context) => const OwnerHomePage(), // Owner home after successful login
      },
    );
  }
}
