import 'package:car_rental_app/services/notification_service.dart';
import 'package:car_rental_app/utils/apptheme.dart/themesettings.dart';
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
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user!.uid,
        'name': widget.name,
        'image': widget.image,
        'price': widget.price,
        'rating': widget.rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => isFavorite = true);
    }
  }

  Future<void> _showBookingDialog() async {
    if (user == null) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.redAccent,
            onPrimary: Colors.white,
            surface: ThemeSettings.cardColor,
            onSurface: ThemeSettings.mainTextColor,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.redAccent,
            onPrimary: Colors.white,
            surface: ThemeSettings.cardColor,
            onSurface: ThemeSettings.mainTextColor,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    DateTime bookingDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    String formattedTime = pickedTime.format(context);

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user!.uid,
        'carName': widget.name,
        'bookingDateTime': bookingDateTime,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Confirmed',
        'price': widget.price,
      });

      await NotificationService.scheduleNotification(
        widget.name.hashCode,
        "Booking Confirmed! 🚗",
        "Aapki ${widget.name} ka pickup time $formattedTime hai.",
        bookingDateTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking Successful! Notification set for $formattedTime",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeSettings.isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeSettings.scaffoldColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
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
                          _sectionLabel("Description"),
                          const SizedBox(height: 10),
                          Text(
                            "Experience the raw power and elegance of the ${widget.name}. Built for those who lead.",
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildTopOverlay(),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBookingBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderImage() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.40,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Hero(tag: widget.name, child: _detailImageLoader(widget.image)),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ThemeSettings.mainTextColor,
                ),
              ),
              Text(
                "Premium Collection",
                style: GoogleFonts.poppins(
                  color: ThemeSettings.isDarkMode.value
                      ? Colors.white54
                      : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeSettings.cardColor, // Changed
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                widget.rating,
                style: TextStyle(color: ThemeSettings.mainTextColor), // Changed
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: ThemeSettings.cardColor, // Changed
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Price",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
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
          const Spacer(),
          ElevatedButton(
            onPressed: _showBookingDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Book Now",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIcon(Icons.arrow_back, () => Navigator.pop(context)),
          _circleIcon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            _toggleFavorite,
            color: isFavorite
                ? Colors.red
                : ThemeSettings.mainTextColor, // Changed
          ),
        ],
      ),
    ),
  );

  Widget _circleIcon(IconData icon, VoidCallback onTap, {Color? color}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeSettings.cardColor, // Changed
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(
            icon,
            color: color ?? ThemeSettings.mainTextColor,
            size: 22,
          ), // Changed
        ),
      );

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: ThemeSettings.mainTextColor, // Changed
    ),
  );

  Widget _buildSpecsGrid() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _specCard(Icons.flash_on, "350 HP"),
      _specCard(Icons.timer, "4.5s"),
      _specCard(Icons.speed, "300km/h"),
    ],
  );

  Widget _specCard(IconData icon, String value) => Container(
    width: (MediaQuery.of(context).size.width - 60) / 3,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: ThemeSettings.cardColor, // Changed
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        Icon(icon, color: Colors.redAccent, size: 20),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: ThemeSettings.mainTextColor, // Changed
          ),
        ),
      ],
    ),
  );

  Widget _detailImageLoader(String path) => path.startsWith('http')
      ? Image.network(path, fit: BoxFit.cover)
      : Image.asset(path, fit: BoxFit.cover);
}
