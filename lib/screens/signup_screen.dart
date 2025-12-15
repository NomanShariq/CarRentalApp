import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- Reusing the established compact dark theme constants ---
const Color tPrimaryColor = Color.fromARGB(255, 187, 56, 56);
const Color tDarkColor = Color(0xFF1E1E2C);
const Color tLightTextColor = Colors.white;
const Color tTextFieldFillColor = Color(0xFF282837);
const String tBackgroundImagePath = 'images/mercedes-2.png';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  Future<void> _signUp() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Basic validation check
    if (_emailController.text.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    // NEW: Check if passwords match
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() => _errorMessage = null);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password,
      );

      Navigator.pushReplacementNamed(context, '/login');
      // Success!
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'The password must be at least 6 characters long.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'An account already exists for that email.';
        } else {
          _errorMessage = e.message;
        }
      });
    }
  }

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
                  color: tPrimaryColor,
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Join REALTAX Today',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: tLightTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your details to create a new account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 223, 222, 222),
                  ),
                ),
                const SizedBox(height: 30),

                _buildSignUpForm(),
                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Login Now',
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

  Widget _buildSignUpForm() {
    return Column(
      children: [
        // Full Name Field
        TextFormField(
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Full Name', Icons.person),
        ),
        const SizedBox(height: 15),

        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Email Address', Icons.email),
        ),
        const SizedBox(height: 15),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
            suffixIcon: _buildVisibilityToggle(_isPasswordVisible, () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            }),
          ),
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: tPrimaryColor, // Use your primary color for visibility
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 15),

        // Confirm Password Field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Confirm Password', Icons.lock_open)
              .copyWith(
                suffixIcon: _buildVisibilityToggle(
                  _isConfirmPasswordVisible,
                  () {
                    setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    );
                  },
                ),
              ),
        ),
        const SizedBox(height: 30),

        // Sign Up Button
        // SizedBox(
        //   width: double.infinity,
        //   height: 48, // Compact height
        //   child: ElevatedButton(
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/home');
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: tPrimaryColor,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //     child: const Text(
        //       'SIGN UP',
        //       style: TextStyle(fontSize: 16, color: tLightTextColor),
        //     ),
        //   ),
        // ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _signUp, // <--- CALL YOUR ASYNC SIGNUP FUNCTION
            style: ElevatedButton.styleFrom(
              backgroundColor: tPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'SIGN UP',
              style: TextStyle(fontSize: 16, color: tLightTextColor),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: tTextFieldFillColor.withOpacity(0.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: tPrimaryColor, width: 2),
      ),
    );
  }

  Widget _buildVisibilityToggle(bool isVisible, VoidCallback toggle) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        size: 20,
        color: Colors.grey.shade500,
      ),
      onPressed: toggle,
    );
  }
}
