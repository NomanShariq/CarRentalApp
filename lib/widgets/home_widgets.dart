import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Reusable Section Title with View All
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionTitle({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                "View All",
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
}

// 2. Optimized Image Loader
Widget imageLoader(dynamic path, double h, {double? width}) {
  String imagePath = path?.toString() ?? "";
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            height: h,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Icon(Icons.car_repair),
          )
        : Image.asset(imagePath, height: h, width: width, fit: BoxFit.cover),
  );
}
