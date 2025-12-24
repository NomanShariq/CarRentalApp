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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // --- Firebase Logic ---
  Future<void> _checkIfFavorite() async {
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: user!.uid)
        .where('name', isEqualTo: widget.name)
        .get();

    if (snapshot.docs.isNotEmpty && mounted) {
      setState(() => isFavorite = true);
    }
  }

  Future<void> _toggleFavorite() async {
    if (user == null) return;
    final collection = FirebaseFirestore.instance.collection('favorites');
    final query = await collection
        .where('userId', isEqualTo: user!.uid)
        .where('name', isEqualTo: widget.name)
        .get();

    if (isFavorite) {
      for (var doc in query.docs) {
        await collection.doc(doc.id).delete();
      }
      setState(() => isFavorite = false);
    } else {
      await collection.add({
        'userId': user!.uid,
        'name': widget.name,
        'image': widget.image,
        'price': widget.price,
        'rating': widget.rating,
      });
      setState(() => isFavorite = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        children: [
          // Main Scrollable Body
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 25),
                      _sectionLabel("Specifications"),
                      const SizedBox(height: 15),
                      _buildSpecsGrid(),
                      const SizedBox(height: 25),
                      _sectionLabel("Features"),
                      const SizedBox(height: 15),
                      _buildFeaturesList(),
                      const SizedBox(height: 25),
                      _sectionLabel("Description"),
                      const SizedBox(height: 10),
                      Text(
                        "Experience luxury and performance with the ${widget.name}. This stunning vehicle combines cutting-edge technology with elegant design.",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(
                        height: 150,
                      ), // Extra space for bottom bars
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Top Buttons
          _buildTopOverlay(),

          // Sticky Bottom Section (Booking + Nav Bar)
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildBookingBar()],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Full Size Image Header
  Widget _buildHeaderImage() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Hero(tag: widget.name, child: _detailImageLoader(widget.image)),
      ),
    );
  }

  // 2. Title & Rating Badge
  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Mercedes", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9EA),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFC33F4C), size: 20),
              const SizedBox(width: 5),
              Text(
                widget.rating,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC33F4C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Booking Bar with Wide Button
  Widget _buildBookingBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Price",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "\$${widget.price}/day",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC33F4C),
                ),
              ),
            ],
          ),
          const SizedBox(width: 60),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC33F4C),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Book Now",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFC33F4C) : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFC33F4C) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // UI Helpers
  Widget _buildTopOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleIcon(Icons.arrow_back, () => Navigator.pop(context)),
            _circleIcon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              _toggleFavorite,
              color: isFavorite ? Colors.red : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _buildSpecsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _specCard(Icons.flash_on, "350 HP", "Power"),
        _specCard(Icons.timer, "4.5s", "0-60 mph"),
        _specCard(Icons.speed, "300 km/h", "Top Speed"),
      ],
    );
  }

  Widget _specCard(IconData icon, String value, String label) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFC33F4C), size: 20),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    List<String> features = ["Bluetooth", "CarPlay", "360 Camera", "GPS"];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: features
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9EA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                f,
                style: const TextStyle(color: Color(0xFFC33F4C), fontSize: 12),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _detailImageLoader(String path) {
    return path.startsWith('http')
        ? Image.network(path, fit: BoxFit.cover)
        : Image.asset(path, fit: BoxFit.cover);
  }
}
