import 'package:flutter/material.dart';

const Color tDarkBackground = Color(0xFF161616);
const Color tPrimaryBlue = Color.fromARGB(255, 209, 37, 37);
const Color tLightColor = Colors.white;
const String tCarImage = 'images/BMW.png';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tDarkBackground,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 80,
              left: 25,
              right: 25,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(tCarImage),
                fit: BoxFit.fitHeight,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.65),
                  BlendMode.darken,
                ),
              ),
            ),

            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to',
                    style: TextStyle(fontSize: 18, color: tLightColor),
                  ),
                  const Text(
                    'RENTALX',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: tLightColor,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  const Spacer(),
                  const FloatingInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingInfoCard extends StatelessWidget {
  const FloatingInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: tPrimaryBlue,
          foregroundColor: tLightColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text('Get Started'),
      ),
    );
  }
}
