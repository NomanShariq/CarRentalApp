import 'package:car_rental_app/screens/cardetail_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:car_rental_app/screens/signup_screen.dart';
import 'package:car_rental_app/screens/welcome_screen.dart';
import 'package:car_rental_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  await Firebase.initializeApp();
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
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/details': (context) =>
            CarDetailScreen(image: '', name: '', rating: '', price: ''),
        '/login': (context) => LoginScreen(),
        '/signUp': (context) => SignupScreen(),
      },
    );
  }
}

class Car {
  final String name, image, rating, price;
  Car({
    required this.name,
    required this.image,
    required this.rating,
    required this.price,
  });
}

// Ye list poori app mein favorites save rakhegi
List<Car> favoriteCars = [];
