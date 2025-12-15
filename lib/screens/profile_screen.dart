import 'package:car_rental_app/screens/login_screen.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color tPrimaryColor = Color.fromARGB(255, 0, 0, 0);
const Color tLightBackground = Colors.white;
const Color tDarkTextColor = Color(0xFF1E1E2C);
const Color tCardColor = Color(0xFFF0F0F0);
const Color tDividerColor = Color(0xFFD0D0D0);

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

  final String _staticProfileImage = "images/Profile.jpg";

  @override
  void initState() {
    super.initState();
    _userName = _user?.displayName ?? 'Not Set';
    _userEmail = _user?.email ?? 'N/A';
    _userPhone = _user?.phoneNumber ?? 'Not Set';
  }

  void _editField(String label, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: tLightBackground,
          title: Text(
            "Edit $label",
            style: const TextStyle(color: tDarkTextColor),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: const Color.fromARGB(221, 24, 23, 23)),
            decoration: const InputDecoration(
              hintText: "Enter new value",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: tPrimaryColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: tPrimaryColor),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() => onSave(controller.text.trim()));
                }
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    try {
      bool nameUpdated = false;
      bool emailChangeInitiated = false;

      // 1. Update Display Name
      if (_user?.displayName != _userName) {
        await _user!.updateDisplayName(_userName);
        nameUpdated = true;
      }

      // 2. Initiate Email Change
      if (_user?.email != _userEmail) {
        await _updateEmail(); // Calls the helper function to send verification email
        emailChangeInitiated = true;
      }

      // 3. Phone Number update (Placeholder logic)
      // Note: Full phone number update requires PhoneAuth flow which is complex.
      if (_user?.phoneNumber != _userPhone && _userPhone != 'Not Set') {
        // Here you would typically call phone update logic (which we are skipping for simplicity)
      }

      // 4. Reload user to sync local state immediately
      await _user!.reload();

      // 5. Provide feedback and navigate
      if (mounted) {
        String successMessage = "Profile saved successfully!";

        if (emailChangeInitiated) {
          successMessage =
              "Check your inbox! An email verification link has been sent to $_userEmail.";
        } else if (nameUpdated) {
          successMessage = "Name updated successfully!";
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));

        // Navigate back only if no email update was initiated (to keep the user focused on the verification step)
        if (!emailChangeInitiated) {
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Failed to update profile: ${e.message}";
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      print("Firebase update error: ${e.code}");
    }
  }

  void _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: tLightBackground,
      appBar: AppBar(
        backgroundColor: tLightBackground,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: tDarkTextColor),
        title: const Text(
          "My Profile",
          style: TextStyle(color: tDarkTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 40),

            _buildEditableInfoField(
              Icons.person_outline,
              "Full Name",
              _userName,
              (v) => _userName = v,
            ),
            _buildEditableInfoField(
              Icons.email_outlined,
              "Email Address",
              _userEmail,
              (v) => _userEmail = v,
            ),
            _buildEditableInfoField(
              Icons.phone_outlined,
              "Phone Number",
              _userPhone,
              (v) => _userPhone = v,
            ),

            const SizedBox(height: 40),

            _buildActionButton(
              text: "Save Changes",
              icon: Icons.save_outlined,
              color: tPrimaryColor,
              onPressed: _saveChanges,
            ),

            const SizedBox(height: 15),

            _buildActionButton(
              text: "Logout",
              icon: Icons.logout,
              color: Colors.red.shade600,
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateEmail() async {
    if (_user == null || _userEmail == _user?.email) {
      return;
    }

    try {
      // Calls Firebase to send a verification link to the new email address.
      // The email property of the user is NOT updated until the user clicks the link.
      await _user!.verifyBeforeUpdateEmail(_userEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification link sent to the new email ($_userEmail). Please check your inbox and click the link to confirm the change.',
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Failed to update email. ";
      if (e.code == 'requires-recent-login') {
        message =
            "Email change failed: Please log in again recently and try immediately after.";
      } else if (e.code == 'invalid-email') {
        message = "The new email address format is invalid.";
      } else if (e.code == 'email-already-in-use') {
        message = "This email is already in use by another account.";
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        // Revert the local state if the update failed
        setState(() {
          _userEmail = _user?.email ?? 'N/A';
        });
      }
      print("Firebase Email Update Error: ${e.code}");
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: tCardColor,
          backgroundImage: AssetImage(_staticProfileImage),
        ),
        const SizedBox(height: 12),
        Text(
          _userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: tDarkTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoField(
    IconData icon,
    String label,
    String value,
    Function(String) onSave,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _editField(label, value, onSave),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                Icon(icon, color: tPrimaryColor, size: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: tDarkTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, color: tPrimaryColor, size: 20),
              ],
            ),
          ),
        ),
        Divider(color: tDividerColor),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: tLightBackground,
          title: const Text(
            "Confirm Logout",
            style: TextStyle(color: tDarkTextColor),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.grey[800]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              onPressed: () {
                Navigator.pop(context);
                _performLogout(context);
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
