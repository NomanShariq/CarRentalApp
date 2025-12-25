import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Bookings",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text("No bookings found"));

          // Latest sorting
          docs.sort((a, b) {
            var t1 =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp? ??
                Timestamp.now();
            var t2 =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp? ??
                Timestamp.now();
            return t2.compareTo(t1);
          });

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              String dTime = "N/A";
              String dDate = "N/A";

              var timestamp = data['bookingTime'] ?? data['bookingDateTime'];
              if (timestamp != null && timestamp is Timestamp) {
                DateTime dt = timestamp.toDate();
                dDate = "${dt.day}/${dt.month}/${dt.year}";
                int h = dt.hour > 12
                    ? dt.hour - 12
                    : (dt.hour == 0 ? 12 : dt.hour);
                String p = dt.hour >= 12 ? "PM" : "AM";
                dTime = "$h:${dt.minute.toString().padLeft(2, '0')} $p";
              }

              return Card(
                child: ListTile(
                  title: Text(
                    data['carName'] ?? "Car",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: ${data['status']}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12),
                          Text(" $dDate  "),
                          const Icon(Icons.access_time, size: 12),
                          Text(" $dTime"),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text("\$${data['price']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
