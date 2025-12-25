import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings') // Aapka data 'bookings' mein hai
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No new notifications"));
          }

          // Latest on Top Sorting
          docs.sort((a, b) {
            Timestamp t1 = a['createdAt'] ?? Timestamp.now();
            Timestamp t2 = b['createdAt'] ?? Timestamp.now();
            return t2.compareTo(t1);
          });

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              // --- 12-HOUR FORMAT LOGIC ---
              String formattedTime = "N/A";
              if (data['createdAt'] != null) {
                DateTime dt = (data['createdAt'] as Timestamp).toDate();
                int hour = dt.hour > 12
                    ? dt.hour - 12
                    : (dt.hour == 0 ? 12 : dt.hour);
                String period = dt.hour >= 12 ? "PM" : "AM";
                String minute = dt.minute.toString().padLeft(2, '0');
                formattedTime = "$hour:$minute $period";
              }

              // --- PICKUP TIME LOGIC (bookingDateTime) ---
              String pickupTime = "N/A";
              if (data['bookingDateTime'] != null) {
                DateTime dtPick = (data['bookingDateTime'] as Timestamp)
                    .toDate();
                int h = dtPick.hour > 12
                    ? dtPick.hour - 12
                    : (dtPick.hour == 0 ? 12 : dtPick.hour);
                String p = dtPick.hour >= 12 ? "PM" : "AM";
                pickupTime =
                    "$h:${dtPick.minute.toString().padLeft(2, '0')} $p";
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE9EA),
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.redAccent,
                    ),
                  ),
                  title: Text(
                    "Reminder: ${data['carName'] ?? 'Car'}", // Braces removed where possible
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Aapka pickup time $pickupTime hai.", // Variable name fixed
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
