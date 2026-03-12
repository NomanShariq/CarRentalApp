import 'package:car_rental_app/utils/apptheme/themesettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeSettings.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: ThemeSettings.scaffoldColor,
          appBar: AppBar(
            title: Text(
              "Notifications",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: ThemeSettings.mainTextColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: ThemeSettings.appBarColor,
            elevation: 0.5,
            iconTheme: IconThemeData(color: ThemeSettings.mainTextColor),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Kuch galat hua hai!",
                    style: TextStyle(color: ThemeSettings.mainTextColor),
                  ),
                );
              }

              var docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    "No new notifications",
                    style: TextStyle(color: ThemeSettings.mainTextColor),
                  ),
                );
              }

              docs.sort((a, b) {
                Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
                Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;
                Timestamp t1 = dataA['createdAt'] ?? Timestamp.now();
                Timestamp t2 = dataB['createdAt'] ?? Timestamp.now();
                return t2.compareTo(t1);
              });

              return ListView.builder(
                itemCount: docs.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;

                  String formattedTime = "Recently";
                  if (data['createdAt'] != null) {
                    DateTime dt = (data['createdAt'] as Timestamp).toDate();
                    int hour = dt.hour > 12
                        ? dt.hour - 12
                        : (dt.hour == 0 ? 12 : dt.hour);
                    String period = dt.hour >= 12 ? "PM" : "AM";
                    formattedTime =
                        "$hour:${dt.minute.toString().padLeft(2, '0')} $period";
                  }

                  String pickupTime = "Not Set";
                  if (data['bookingDateTime'] != null) {
                    DateTime dtPick = (data['bookingDateTime'] as Timestamp)
                        .toDate();
                    int h = dtPick.hour > 12
                        ? dtPick.hour - 12
                        : (dtPick.hour == 0 ? 12 : dtPick.hour);
                    pickupTime =
                        "$h:${dtPick.minute.toString().padLeft(2, '0')} ${dtPick.hour >= 12 ? "PM" : "AM"}";
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeSettings.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white10
                            : Colors.grey.shade200,
                      ),
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
                        "Reminder: ${data['carName'] ?? 'Car'}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeSettings.mainTextColor,
                        ),
                      ),
                      subtitle: Text(
                        "Aapka pickup time $pickupTime hai.",
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeSettings.secondaryTextColor,
                        ),
                      ),
                      trailing: Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
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
