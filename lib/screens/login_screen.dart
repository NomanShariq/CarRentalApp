import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Reuse constants
const Color tPrimaryColor = Color.fromARGB(255, 187, 56, 56);
const Color tDarkColor = Color(0xFF1E1E2C);
const Color tLightTextColor = Colors.white;
const Color tTextFieldFillColor = Color(0xFF282837);
const String tBackgroundImagePath = 'images/mercedes-2.png';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(tBackgroundImagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 200),
                const Icon(
                  Icons.directions_car_filled,
                  color: Color.fromARGB(255, 187, 56, 56),
                  size: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Login ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: tLightTextColor,
                  ),
                ),
                const SizedBox(height: 10),

                _buildLoginForm(context),
                const SizedBox(height: 20),

                const Text(
                  'Or connect with',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildSocialLoginButtons(),
                const SizedBox(height: 30),

                // --- Sign Up Link ---
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade400),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: tPrimaryColor,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Email Address', Icons.email),
        ),
        const SizedBox(height: 20),
        TextFormField(
          obscureText: !_isPasswordVisible,
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: tPrimaryColor),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'LOGIN',
              style: TextStyle(fontSize: 18, color: tLightTextColor),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      filled: true,
      fillColor: tTextFieldFillColor.withOpacity(0.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: tPrimaryColor, width: 2),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          FontAwesomeIcons.facebookF,
          Colors.blue.shade800,
          () {},
        ),
        const SizedBox(width: 20),
        _buildSocialButton(FontAwesomeIcons.google, Colors.white, () {}),
        const SizedBox(width: 20),

        _buildSocialButton(FontAwesomeIcons.instagram, Colors.purple, () {}),
      ],
    );
  }

  Widget _buildSocialButton(
    IconData iconData,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: tTextFieldFillColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: IconButton(
        iconSize: 24,
        onPressed: onPressed,
        icon: FaIcon(iconData, color: color),
        padding: const EdgeInsets.all(10.0),
      ),
    );
  }
}
