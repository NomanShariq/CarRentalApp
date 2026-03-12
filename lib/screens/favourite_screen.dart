import 'package:car_rental_app/main.dart';
import 'package:car_rental_app/utils/apptheme/themesettings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeSettings.isDarkMode,
      builder: (context, isDark, child) {
        print("Dark Mode is: $isDark");
        return Container(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text(
                "My Favorites ❤️",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ThemeSettings.mainTextColor,
                ),
              ),
            ),
            body: favoriteCars.isEmpty
                ? Center(
                    child: Text(
                      "Koi favorite car nahi mili!",
                      style: GoogleFonts.poppins(
                        color: ThemeSettings.mainTextColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: favoriteCars.length,
                    itemBuilder: (context, index) {
                      final car = favoriteCars[index];
                      return _buildFavoriteCard(car, isDark);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(dynamic car, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeSettings.cardColor, // FIX: Card ka color bhi change hoga
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              car.image,
              width: 100,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Brand",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  car.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeSettings.mainTextColor,
                  ),
                ),
                Text(
                  "\$${car.price}/day",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.delete_outline, color: Colors.redAccent),
        ],
      ),
    );
  }
}
