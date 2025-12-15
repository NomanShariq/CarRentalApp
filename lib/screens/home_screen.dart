import 'package:car_rental_app/screens/addnewcar_screen.dart';
import 'package:car_rental_app/screens/cardetail_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedindex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final double cardWidth = 195;
  final List<Map<String, String>> featuredCars = [
    {
      "image": "images/Tesla.png",
      "name": "Tesla Model 3",
      "rating": "4.8",
      "price": "100.0/day",
    },
    {
      "image": "images/Mmw-m4.png",
      "name": "BMW M4",
      "rating": "4.9",
      "price": "150.0/day",
    },
    {
      "image": "images/Mercedes.jpg",
      "name": "Mercedes C Class",
      "rating": "4.7",
      "price": "200.0/day",
    },
    {
      "image": "images/Audi.png",
      "name": "Audi A4",
      "rating": "4.6",
      "price": "120.0/day",
    },
  ];

  @override
  void initState() {
    super.initState();
    // 🔑 Listen for scroll events to update the indicator
    _scrollController.addListener(_updatePageIndicator);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updatePageIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  void _updatePageIndicator() {
    double scrollOffset = _scrollController.offset;
    int firstVisibleIndex = (scrollOffset / cardWidth).round();

    // We only want 3 indicator dots, so we cap the page index.
    // int maxPages = featuredCars.length - 1;

    int newPage = 0;
    if (firstVisibleIndex >= 2) {
      newPage = 2;
    } else if (firstVisibleIndex >= 1) {
      newPage = 1;
    }

    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int indicatorCount = 3;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        // snapshot.data holds the current user (User?)
        final User? currentUser = snapshot.data;

        // Determine the text to display: Name > Email > Fallback
        final String displayName =
            currentUser?.displayName ?? currentUser?.email ?? "Welcome";
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Car Rental",
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.black,
                    backgroundImage: AssetImage('images/Profile.jpg'),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddNewCarScreen(onCarAdded: (_) {}),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300, // 👈 border color
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: selectedindex,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: true,
              onTap: (index) {
                setState(() {
                  selectedindex = index;
                });
                // Navigation logic...
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_filled,
                    color: selectedindex == 0 ? Colors.redAccent : Colors.black,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.search,
                    color: selectedindex == 1 ? Colors.redAccent : Colors.black,
                  ),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.favorite_border,
                    color: selectedindex == 2 ? Colors.redAccent : Colors.black,
                  ),
                  label: "Favorites",
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 195, 63, 76),
                        const Color.fromARGB(255, 17, 9, 23),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _currentUser?.displayName ?? "Find your dream car",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // SEARCH BAR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey.shade600),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: "Search for your dream car",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.tune_rounded,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          "Categories",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // CATEGORIES
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _categoryChip("All", true),
                              const SizedBox(width: 10),
                              _categoryChip("Tesla", false),
                              const SizedBox(width: 10),
                              _categoryChip("BMW", false),
                              const SizedBox(width: 10),
                              _categoryChip("Mercedes", false),
                              const SizedBox(width: 10),
                              _categoryChip("Audi", false),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// FEATURED CARS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Featured Cars",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "View All",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: featuredCars.map((car) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: _featuredCar(
                                  image: car["image"]!,
                                  name: car["name"]!,
                                  rating: car["rating"]!,
                                  price: car["price"]!,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔑 DOT INDICATOR ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            indicatorCount, // Use the fixed count for indicators
                            (index) => _buildDotIndicator(index),
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// POPULAR DEALS TITLE
                        Text(
                          "Popular Deals",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// POPULAR DEALS LIST
                        _popularDeal(
                          "Tesla",
                          "Tesla Model 3",
                          "4.8",
                          "100.0/day",
                          "images/Mercedes.jpg",
                        ),
                        _popularDeal(
                          "BMW",
                          "BMW M4",
                          "4.9",
                          "150.0/day",
                          "images/Mercedes.jpg",
                        ),
                        _popularDeal(
                          "Mercedes",
                          "Mercedes C class",
                          "4.7",
                          "200.0/day",
                          "images/Mercedes.jpg",
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 20.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.redAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// CATEGORY CHIP
  Widget _categoryChip(String text, bool selected) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.redAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// FEATURED CAR CARD (Re-added fixed width)
  Widget _featuredCar({
    required String image,
    required String name,
    required String rating,
    required String price,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailScreen(
              image: image,
              name: name,
              rating: rating,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        width: 180, // Fixed width for calculating scroll position
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(image, height: 100, width: double.maxFinite),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "\$$price",
              style: const TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  /// POPULAR DEAL LIST TILE
  Widget _popularDeal(
    String subname,
    String name,
    String rating,
    String price,
    String image,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailScreen(
              image: image,
              name: name,
              rating: rating,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 90,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subname,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$$price",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Book Now",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
