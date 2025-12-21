import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarDetailScreen extends StatefulWidget {
  final String image;
  final String name;
  final String rating;
  final String price;

  const CarDetailScreen({
    super.key,
    required this.image,
    required this.name,
    required this.rating,
    required this.price,
  });

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool isFavorite = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Check if this car is already in user's favorites
  Future<void> _checkIfFavorite() async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user!.uid)
        .where('name', isEqualTo: widget.name)
        .get();

    if (snapshot.docs.isNotEmpty) {
      if (mounted) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  // Toggle Favorite Status
  Future<void> _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add favorites")),
      );
      return;
    }

    final collection = FirebaseFirestore.instance.collection('favorites');
    final query = await collection
        .where('userId', isEqualTo: user!.uid)
        .where('name', isEqualTo: widget.name)
        .get();

    if (isFavorite) {
      // Remove from Firestore
      for (var doc in query.docs) {
        await collection.doc(doc.id).delete();
      }
      if (mounted) {
        setState(() => isFavorite = false);
      }
      _showSnackBar("${widget.name} removed from Favorites");
    } else {
      // Add to Firestore
      await collection.add({
        'userId': user!.uid,
        'name': widget.name,
        'image': widget.image,
        'price': widget.price,
        'rating': widget.rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() => isFavorite = true);
      }
      _showSnackBar("${widget.name} added to Favorites ❤️");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image Header
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Hero(
                  tag: widget.name,
                  child: _detailImageLoader(widget.image),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _ratingBadge(widget.rating),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Premium Rental Car",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This ${widget.name} offers a smooth driving experience with top-notch features. Perfect for both city travels and long-distance journeys with maximum fuel efficiency.",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _featureIcon(Icons.speed, "240km/h"),
                      _featureIcon(Icons.settings_input_component, "Auto"),
                      _featureIcon(Icons.local_gas_station, "Petrol"),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Price", style: TextStyle(color: Colors.grey)),
              Text(
                "\$${widget.price}/day",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {}, // Aapka booking logic yahan ayega
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF110917),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Book Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBadge(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 5),
          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _featureIcon(IconData icon, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _detailImageLoader(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => const Icon(Icons.car_repair, size: 100),
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => const Icon(Icons.car_repair, size: 100),
      );
    }
  }
}
