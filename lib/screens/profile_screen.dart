import 'package:car_rental_app/screens/home_screen.dart';
import 'package:car_rental_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

// --- Theme Constants ---
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
  // Editable fields
  String _userName = 'Syed Noman Shariq';
  String _userEmail = 'Nom87@gmail.com';
  String _userPhone = '+92 313 1234567';

  final String _staticProfileImage = "images/Profile.jpg";

  // Edit dialog
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

  @override
  Widget build(BuildContext context) {
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

            // Editable fields
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile updated successfully!"),
                  ),
                );
              },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully!")),
                );
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
