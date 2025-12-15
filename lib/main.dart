import 'package:car_rental_app/screens/cardetail_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:car_rental_app/screens/signup_screen.dart';
import 'package:car_rental_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Rental App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        // Route 1: The home screen
        '/home': (context) => const HomeScreen(),
        // Route 2: Welcome screen
        '/profile': (context) => ProfileScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        // // Route 4: Details screen
        '/details': (context) =>
            CarDetailScreen(image: '', name: '', rating: '', price: ''),
        // Route 5: Login screen
        '/login': (context) => LoginScreen(),
        // Route 5: SignUp screen
        '/signUp': (context) => SignupScreen(),
      },
    );
  }
}
