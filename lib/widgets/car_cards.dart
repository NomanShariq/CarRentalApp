import 'package:car_rental_app/screens/cardetail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarCards {
  // 1. Optimized Image Loader
  static Widget _imageLoader(dynamic path, double h, {double? width}) {
    String imagePath = path?.toString() ?? "";
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: imagePath.startsWith('http')
          ? Image.network(
              imagePath,
              height: h,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.car_repair),
              ),
            )
          : Image.asset(imagePath, height: h, width: width, fit: BoxFit.cover),
    );
  }

  // 2. FEATURED CARD (Jo error de raha tha)
  static Widget featuredCard(BuildContext context, Map<String, dynamic> car) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => CarDetailScreen(
              image: car['image'] ?? '',
              name: car['name'] ?? 'Car',
              rating: (car['rating'] ?? 0).toString(),
              price: (car['price'] ?? 0).toString(),
            ),
          ),
        ),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageLoader(car['image'], 100, width: double.infinity),
              const SizedBox(height: 10),
              Text(
                car['name'] ?? 'Car',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text(" ${car['rating'] ?? 0}"),
                ],
              ),
              const Spacer(), // Price ko niche push karne ke liye
              Text(
                "\$${car['price'] ?? 0}/day",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Popular Deal Card (Tesla Style)
  static Widget popularDealCard(
    BuildContext context,
    Map<String, dynamic> car,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => CarDetailScreen(
            image: car['image'] ?? '',
            name: car['name'] ?? 'Car',
            rating: (car['rating'] ?? 0).toString(),
            price: (car['price'] ?? 0).toString(),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _imageLoader(car['image'], 80, width: 110),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car['name'] ?? 'Car Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${car['rating'] ?? 4.8}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${car['price']}/day",
                        style: const TextStyle(
                          color: Color(0xFFC33F4C),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC33F4C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(
                            color: Color(0xFFC33F4C),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Popular Deals Section Builder
  static Widget buildPopularDealsFirestore(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cars')
          .where('isFeatured', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Text("No popular deals.");

        return Column(
          children: snapshot.data!.docs.map((doc) {
            return popularDealCard(context, doc.data() as Map<String, dynamic>);
          }).toList(),
        );
      },
    );
  }
}
