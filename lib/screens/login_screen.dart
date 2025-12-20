import 'package:car_rental_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    setState(() => _errorMessage = null);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null && user.displayName == null) {
        final defaultName = email.split('@')[0];

        await user.updateDisplayName(defaultName);

        await user.reload();
        print('User name updated successfully to: $defaultName');
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'The email address is invalid.';
        } else {
          _errorMessage = e.message;
        }
      });
      print("Login failed with Firebase exception: ${e.code}");
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
      print("Login failed with general error: $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Google Sign-In failed.');
      print("Error details: $e");
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
          controller: _emailController,
          style: const TextStyle(color: tLightTextColor),
          decoration: _buildInputDecoration('Email Address', Icons.email),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
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
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: tPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: _emailController.text.trim(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent to email!'),
                  ),
                );
              } catch (e) {
                print(e);
              }
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: tPrimaryColor),
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _signIn,
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
        _buildSocialButton(
          FontAwesomeIcons.google,
          Colors.white,
          _signInWithGoogle,
        ),
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
