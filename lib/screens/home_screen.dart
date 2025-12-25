import 'package:car_rental_app/screens/addnewcar_screen.dart';
import 'package:car_rental_app/screens/allcars_screen.dart';
import 'package:car_rental_app/screens/booking_history.dart';
import 'package:car_rental_app/screens/cardetail_screen.dart';
import 'package:car_rental_app/screens/notication_screen.dart';
import 'package:car_rental_app/screens/profile_screen.dart';
import 'package:car_rental_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int navIndex = 0;
  int categoryIndex = 0;
  String selectedCategory = "All";
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final double cardWidth = 195;
  String sortBy = "None";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updatePageIndicator);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updatePageIndicator);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updatePageIndicator() {
    if (!_scrollController.hasClients) return;
    double scrollOffset = _scrollController.offset;
    int firstVisibleIndex = (scrollOffset / cardWidth).round();
    int newPage = firstVisibleIndex.clamp(0, 2);
    if (_currentPage != newPage) {
      setState(() => _currentPage = newPage);
    }
  }

  void _navigateToViewAll(
    BuildContext context,
    String title, {
    String? category,
    bool onlyFeatured = false,
    bool onlyPopular = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => AllCarsScreen(
          title: title,
          category: category,
          onlyFeatured: onlyFeatured,
          onlyPopular: onlyPopular,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, authSnapshot) {
        final User? currentUser = authSnapshot.data;
        final String displayName =
            currentUser?.displayName ?? currentUser?.email ?? "Welcome";

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context),
          floatingActionButton: _buildFAB(context),
          bottomNavigationBar: _buildBottomNav(),
          body: navIndex == 2
              ? _buildFavoritesScreen()
              : SafeArea(
                  child: Column(
                    children: [
                      _buildGradientHeader(displayName),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              if (_searchQuery.isNotEmpty) ...[
                                _sectionTitle("Matching Results 🔍"),
                                const SizedBox(height: 15),
                                _buildSearchSection(),
                                const SizedBox(height: 30),
                              ],
                              _sectionTitle("Categories"),
                              const SizedBox(height: 15),
                              _buildDynamicCategories(),

                              const SizedBox(height: 30),
                              _sectionTitle(
                                selectedCategory == "All"
                                    ? "All Collections"
                                    : "$selectedCategory Collections",
                                onViewAll: () => _navigateToViewAll(
                                  context,
                                  "Collections",
                                  category: selectedCategory,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildCategorySpecificHorizontal(),

                              const SizedBox(height: 30),
                              _sectionTitle(
                                "Featured Cars",
                                onViewAll: () => _navigateToViewAll(
                                  context,
                                  "Featured Cars",
                                  onlyFeatured: true,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildFeaturedCarsFirestore(),

                              const SizedBox(height: 10),
                              _buildDotIndicatorRow(),

                              const SizedBox(height: 30),
                              _sectionTitle(
                                "Popular Deals",
                                onViewAll: () => _navigateToViewAll(
                                  context,
                                  "Popular Deals",
                                  onlyPopular: true,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildPopularDealsFirestore(),

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

  Widget _buildCategorySpecificHorizontal() {
    Query query = FirebaseFirestore.instance.collection('cars');

    if (selectedCategory != "All") {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text("No cars found.");
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: docs
                .map(
                  (doc) => _featuredCarCard(doc.data() as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGradientHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC33F4C), Color(0xFF110917)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Find your dream car",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => NotificationScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const BookingHistoryScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: "Search cars...",
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
              child: const Icon(Icons.clear, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildDynamicCategories() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        List<String> categories = ["All"];
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            String name = doc['name'] ?? "";
            if (name.isNotEmpty && name != "All") categories.add(name);
          }
        }
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              bool isSelected = categoryIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() {
                    categoryIndex = index;
                    selectedCategory = categories[index];
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.redAccent
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCarsFirestore() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cars')
          .where('isFeatured', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snapshot.data!.docs;
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: docs
                .map(
                  (doc) => _featuredCarCard(doc.data() as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _featuredCarCard(Map<String, dynamic> car) {
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
              _imageLoader(car['image'], 100),
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

  Widget _buildPopularDealsFirestore() {
    Query query = FirebaseFirestore.instance
        .collection('cars')
        .where('isFeatured', isEqualTo: false);
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var cars = snapshot.data!.docs;
        return Column(
          children: cars
              .map(
                (doc) => _popularDealCard(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFavoritesScreen() {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "My Favorites ❤️",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No favorites yet!",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }
          var favDocs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              var car = favDocs[index].data() as Map<String, dynamic>;
              return _popularDealCard(car, isFavoriteScreen: true);
            },
          );
        },
      ),
    );
  }

  Widget _popularDealCard(
    Map<String, dynamic> car, {
    bool isFavoriteScreen = false,
  }) {
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            _imageLoader(car['image'], 60, width: 80),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car['category'] ?? 'Brand',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    car['name'] ?? 'Car',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "\$${car['price'] ?? 0}/day",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),

            isFavoriteScreen
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      var snapshot = await FirebaseFirestore.instance
                          .collection('favorites')
                          .where('userId', isEqualTo: user.uid)
                          .where('name', isEqualTo: car['name'])
                          .get();

                      for (var doc in snapshot.docs) {
                        await doc.reference.delete();
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Removed from Favorites")),
                      );
                    },
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _imageLoader(dynamic path, double h, {double? width}) {
    String imagePath = path?.toString() ?? "";
    if (imagePath.isEmpty) return Icon(Icons.car_repair, size: h);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imagePath.startsWith('http')
          ? Image.network(
              imagePath,
              height: h,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
            )
          : Image.asset(
              imagePath,
              height: h,
              width: width,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
            ),
    );
  }

  Widget _buildDotIndicatorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == i ? 20 : 8,
          decoration: BoxDecoration(
            color: _currentPage == i ? Colors.redAccent : Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        var searchResults = snapshot.data!.docs.where((doc) {
          String carName = (doc['name'] ?? "").toString().toLowerCase();
          return carName.contains(_searchQuery.toLowerCase());
        }).toList();

        if (searchResults.isEmpty) {
          return Text(
            "No cars found for '$_searchQuery'",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: searchResults
                .map(
                  (doc) => _featuredCarCard(doc.data() as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text(
      "Car Rental",
      style: GoogleFonts.poppins(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const ProfileScreen()),
        ),
        icon: const CircleAvatar(
          backgroundImage: AssetImage('images/Profile.jpg'),
        ),
      ),
    ],
  );

  Widget _buildFAB(BuildContext context) => FloatingActionButton(
    backgroundColor: Colors.redAccent,
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewCarScreen()),
    ),
    child: const Icon(Icons.add, color: Colors.white),
  );

  Widget _buildBottomNav() => BottomNavigationBar(
    currentIndex: navIndex,
    selectedItemColor: Colors.redAccent,
    unselectedItemColor: Colors.black,
    onTap: (i) => setState(() => navIndex = i),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        label: "Favorites",
      ),
    ],
  );
}
