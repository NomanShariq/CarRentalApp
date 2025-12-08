import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedindex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black87),
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
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.black,

              backgroundImage: AssetImage('images/Profile.jpg'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedindex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        onTap: (index) {
          setState(() {
            selectedindex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }
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
              color: selectedindex == 2 ? Colors.redAccent : Colors.black,
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              color: selectedindex == 1 ? Colors.redAccent : Colors.black,
            ),
            label: "Favorites",
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 195, 63, 76),
                    Color.fromARGB(255, 17, 9, 23),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Syed Noman Shariq",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Find your dream car",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),

                  // SEARCH BAR
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Search for your dream car",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.tune_rounded, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Categories",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 15),

                    Scrollable(
                      viewportBuilder:
                          (BuildContext context, ViewportOffset position) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _categoryChip("All", true),
                                  SizedBox(width: 10),
                                  _categoryChip("Tesla", false),
                                  SizedBox(width: 10),
                                  _categoryChip("BMW", false),
                                  SizedBox(width: 10),
                                  _categoryChip("Mercedes", false),
                                  SizedBox(width: 10),
                                  _categoryChip("Audi", false),
                                ],
                              ),
                            );
                          },
                      // children: [
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       _categoryChip("All", true),
                      //       _categoryChip("Tesla", false),
                      //       _categoryChip("BMW", false),
                      //       _categoryChip("Mercedes", false),
                      //       _categoryChip("Mercedes", false),
                      //     ],
                      //   ),
                      // ],
                    ),

                    SizedBox(height: 30),

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
                          child: Text(
                            "View All",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    /// FEATURED CAR CARDS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _featuredCar(
                            image: "images/Mercedes.jpg",
                            name: "Tesla Model 3",
                            rating: "4.8",
                            price: "100.0/day",
                          ),
                          SizedBox(width: 15),
                          _featuredCar(
                            image: "images/Mercedes.jpg",
                            name: "BMW M4",
                            rating: "4.9",
                            price: "150.0/day",
                          ),
                          SizedBox(width: 15),
                          _featuredCar(
                            image: "images/Mercedes.jpg",
                            name: "BMW M4",
                            rating: "4.9",
                            price: "150.0/day",
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    /// POPULAR DEALS TITLE
                    Text(
                      "Popular Deals",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 20),

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

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CATEGORY CHIP
  Widget _categoryChip(String text, bool selected) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
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

  /// FEATURED CAR CARD
  Widget _featuredCar({
    required String image,
    required String name,
    required String rating,
    required String price,
  }) {
    return Container(
      width: 180,
      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 4,
        //     offset: Offset(1, 1),
        //     spreadRadius: 2,
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            child: Image.asset(image, height: 100, width: double.maxFinite),
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text(rating, style: TextStyle(color: Colors.black87)),
            ],
          ),
          SizedBox(height: 5),
          Text(
            "\$$price",
            style: TextStyle(color: Colors.redAccent, fontSize: 15),
          ),
        ],
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
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, width: 90, height: 60, fit: BoxFit.cover),
          ),
          SizedBox(width: 15),
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
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text(rating, style: TextStyle(color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 4),
                Text("\$$price", style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // rounded corners
              ),
            ),
            onPressed: () {},
            child: Text(
              "Book Now",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
