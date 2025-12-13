import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Theme Constants (Reuse the Primary Color for consistency)
const Color tPrimaryColor = Color(0xFF6C63FF);
const Color tDarkTextColor = Color(0xFF1E1E2C);

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: tDarkTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.name,
          style: GoogleFonts.poppins(
            color: tDarkTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.redAccent,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                // Optional feedback:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? '${widget.name} added to favorites!'
                          : '${widget.name} removed from favorites.',
                    ),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarImageSection(context),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      _buildTitleAndRating(),
                      const SizedBox(height: 10),

                      _buildUserPostInfo(),
                      const SizedBox(height: 30),

                      _buildDescription(),
                      const SizedBox(height: 20),

                      _buildSpecificationsGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildFloatingRentButton(context),
        ],
      ),
    );
  }

  Widget _buildCarImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Image.asset(
        widget.image,
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.35,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitleAndRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.name,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: tDarkTextColor,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 5),
              Text(
                widget.rating,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: tDarkTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserPostInfo() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('images/Profile.jpg'),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Posted by Syed Noman Shariq",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tDarkTextColor,
              ),
            ),
            Text(
              "2 hours ago",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tDarkTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "The ${widget.name} is the perfect blend of electric performance and modern luxury. Known for its quick acceleration, spacious interior, and advanced tech features, it’s ideal for weekend trips or city driving.",
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Specifications",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tDarkTextColor,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _specItem(Icons.speed, "250 km/h", "Max Speed"),
            _specItem(Icons.ac_unit, "Auto", "A/C"),
            _specItem(Icons.local_gas_station, "Electric", "Fuel Type"),
          ],
        ),
      ],
    );
  }

  Widget _specItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.redAccent, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: tDarkTextColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFloatingRentButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              spreadRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Price",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  "\$${widget.price}",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Renting ${widget.name} for \$${widget.price}',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                child: const Text(
                  "Rent Now",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
