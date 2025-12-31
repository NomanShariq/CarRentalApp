import 'package:car_rental_app/utils/apptheme.dart/themesettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  Future<void> _showClearAllDialog(BuildContext context, String userId) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeSettings.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Clear History?",
          style: GoogleFonts.poppins(
            color: ThemeSettings.mainTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete all your booking history? This cannot be undone.",
          style: GoogleFonts.poppins(color: ThemeSettings.mainTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: ThemeSettings.mainTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              navigator.pop();

              try {
                final batch = FirebaseFirestore.instance.batch();
                final snapshots = await FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: userId)
                    .get();

                for (var doc in snapshots.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();

                if (!mounted) return;

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text("History cleared successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Clear All",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeSettings.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: ThemeSettings.scaffoldColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: ThemeSettings.cardColor,
            iconTheme: IconThemeData(color: ThemeSettings.mainTextColor),
            title: Text(
              "My Bookings",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: ThemeSettings.mainTextColor,
              ),
            ),
            actions: [
              if (user != null)
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                  onPressed: () => _showClearAllDialog(context, user.uid),
                ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('userId', isEqualTo: user?.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Building Index... Please wait 5 minutes.\n\nCheck your browser to confirm the index is 'Building'.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No bookings found",
                    style: GoogleFonts.poppins(
                      color: ThemeSettings.mainTextColor,
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                padding: const EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  // Date Formatting Logic
                  String dDate = "N/A";
                  final ts = data['createdAt'] ?? data['bookingDateTime'];
                  if (ts is Timestamp) {
                    final dt = ts.toDate();
                    dDate = "${dt.day}/${dt.month}/${dt.year}";
                  }

                  return Card(
                    color: ThemeSettings.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        data['carName'] ?? "Car",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: ThemeSettings.mainTextColor,
                        ),
                      ),
                      subtitle: Text(
                        "Booked on: $dDate\nStatus: ${data['status']}",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      trailing: Text(
                        data['price'] != null ? "\$${data['price']}" : "N/A",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
