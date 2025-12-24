import 'package:car_rental_app/widgets/car_cards.dart'; // Apna widget import karein
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllCarsScreen extends StatefulWidget {
  final String title;
  final String? category;
  final bool onlyFeatured;
  final bool onlyPopular;

  const AllCarsScreen({
    super.key,
    required this.title,
    this.category,
    this.onlyFeatured = false,
    this.onlyPopular = false,
  });

  @override
  State<AllCarsScreen> createState() => _AllCarsScreenState();
}

class _AllCarsScreenState extends State<AllCarsScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Query Logic
    Query query = FirebaseFirestore.instance.collection('cars');

    if (widget.category != null && widget.category != "All") {
      query = query.where('category', isEqualTo: widget.category);
    }
    if (widget.onlyFeatured) {
      query = query.where('isFeatured', isEqualTo: true);
    }
    if (widget.onlyPopular) {
      query = query.where('isFeatured', isEqualTo: false);
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FB,
      ), // Thoda off-white background professional lagta hai
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No cars found in this section."));
          }

          var docs = snapshot.data!.docs;

          // 2. Conditional Layout Logic
          // Agar Popular Deals hain to ListView (Tesla Style)
          if (widget.onlyPopular) {
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var car = docs[index].data() as Map<String, dynamic>;
                // Hum wahi card use kar rahe hain jo humne pehle banaya tha
                return CarCards.popularDealCard(context, car);
              },
            );
          }

          // 3. Featured ya All Cars ke liye GridView
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var car = docs[index].data() as Map<String, dynamic>;
              return _gridCard(context, car);
            },
          );
        },
      ),
    );
  }

  // Grid Card Design for Featured/All Cars
  Widget _gridCard(BuildContext context, Map<String, dynamic> car) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: car['image'] != null
                  ? Image.network(car['image'], fit: BoxFit.contain)
                  : const Icon(Icons.car_rental, size: 50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            car['name'] ?? 'Car',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "\$${car['price']}/day",
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
