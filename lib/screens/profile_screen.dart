// ignore_for_file: use_build_context_synchronously

import 'package:car_rental_app/screens/login_screen.dart';
import 'package:car_rental_app/utils/apptheme/themesettings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  late String _userName;
  late String _userEmail;
  String _userPhone = 'Not Set';
  String? _verificationId;

  final String _staticProfileImage = "images/Profile.jpg";

  @override
  void initState() {
    super.initState();
    _userName = _user?.displayName ?? 'Not Set';
    _userEmail = _user?.email ?? 'N/A';
    _userPhone = _user?.phoneNumber ?? 'Not Set';
  }

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _user?.updatePhoneNumber(credential);
        setState(() => _userPhone = phoneNumber);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _showOTPDialog(phoneNumber);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _showOTPDialog(String phoneNumber) {
    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeSettings.cardColor,
        title: Text("Enter OTP",
            style: TextStyle(color: ThemeSettings.mainTextColor)),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style:
              TextStyle(color: ThemeSettings.mainTextColor, letterSpacing: 8),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId!,
                  smsCode: otpController.text.trim(),
                );
                await _user?.updatePhoneNumber(credential);
                Navigator.pop(context);
                setState(() => _userPhone = phoneNumber);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
              }
            },
            child: const Text("Verify", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editField(String label, String currentValue, Function(String) onSave) {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ThemeSettings.cardColor,
        title: Text("Edit $label",
            style: TextStyle(color: ThemeSettings.mainTextColor)),
        content: TextField(
          controller: controller,
          keyboardType: label == "Phone Number"
              ? TextInputType.phone
              : TextInputType.text,
          style: TextStyle(color: ThemeSettings.mainTextColor),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              String newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                if (label == "Phone Number") {
                  Navigator.pop(context);
                  _verifyPhoneNumber(newValue);
                } else {
                  setState(() => onSave(newValue));
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;
    try {
      if (_user?.displayName != _userName) {
        await _user?.updateDisplayName(_userName);
      }
      if (_user?.email != _userEmail) await _user?.updateEmail(_userEmail);

      await _user?.reload();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profile Updated!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeSettings.scaffoldColor,
      appBar: AppBar(
        backgroundColor: ThemeSettings.appBarColor,
        title: Text("My Profile",
            style: TextStyle(color: ThemeSettings.mainTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            CircleAvatar(
                radius: 60, backgroundImage: AssetImage(_staticProfileImage)),
            const SizedBox(height: 40),
            _buildInfoTile(
                Icons.person, "Full Name", _userName, (v) => _userName = v),
            _buildInfoTile(Icons.email, "Email Address", _userEmail,
                (v) => _userEmail = v),
            _buildInfoTile(
                Icons.phone, "Phone Number", _userPhone, (v) => _userPhone = v),
            const SizedBox(height: 40),
            _buildButton("Save Changes", Colors.redAccent, _saveChanges),
            const SizedBox(height: 15),
            _buildButton("Logout", Colors.grey, () => _performLogout(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Function(String) onSave) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(label,
          style:
              TextStyle(color: ThemeSettings.secondaryTextColor, fontSize: 12)),
      subtitle: Text(value,
          style: TextStyle(color: ThemeSettings.mainTextColor, fontSize: 16)),
      trailing: const Icon(Icons.edit, color: Colors.redAccent, size: 20),
      onTap: () => _editField(label, value, onSave),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
