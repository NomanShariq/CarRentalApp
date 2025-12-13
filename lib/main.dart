import 'package:car_rental_app/screens/home_screen.dart';
import 'package:car_rental_app/screens/login_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:car_rental_app/screens/signup_screen.dart';
import 'package:car_rental_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: WelcomeScreen(),
      routes: {
        // Route 1: The home screen
        '/home': (context) => const HomeScreen(),
        // Route 2: Welcome screen
        '/profile': (context) => ProfileScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        // // Route 4: Details screen
        // '/details': (context) => const DetailsScreen(),
        // Route 5: Login screen
        '/login': (context) => LoginScreen(),
        // Route 5: SignUp screen
        '/signUp': (context) => SignupScreen(),
      },
    );
  }
}
