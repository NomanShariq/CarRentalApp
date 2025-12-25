import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewCarScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onCarAdded;
  const AddNewCarScreen({super.key, this.onCarAdded});
  @override
  State<AddNewCarScreen> createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  String _carAvailability = 'Rent';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final List<String> staticImageAssets = [
        "images/Mercedes.jpg",
        "images/Mercedes.jpg",
      ];
      final String priceSuffix = _carAvailability == 'Rent' ? 'day' : 'sale';

      final newCar = {
        "images": staticImageAssets,
        "name": _nameController.text,
        "price": "${_priceController.text}/$priceSuffix",
        "rating": _ratingController.text,
        "availability": _carAvailability,
      };

      if (widget.onCarAdded != null) {
        widget.onCarAdded!(newCar);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Car "${newCar['name']}" posted for $_carAvailability!',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Post Your Car",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,

        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Car Details",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _nameController,
                label: "Car Name",
                icon: Icons.directions_car,
              ),

              _buildTextField(
                controller: _priceController,
                label: "Price per Day/Sale Amount",
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _ratingController,
                label: "Rating (1.0 to 5.0)",
                icon: Icons.star,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) > 5.0 ||
                      double.parse(value) < 1.0) {
                    return 'Enter a valid rating (1.0 to 5.0)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              Text(
                "Availability Type",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildAvailabilityDropdown(),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Post Car",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: DropdownButton<String>(
            value: _carAvailability,
            isExpanded: true,
            icon: const Icon(Icons.arrow_downward, color: Colors.redAccent),
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            items: const <String>['Rent', 'Sale'].map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _carAvailability = newValue!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        style: TextStyle(color: Colors.black87),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color.fromARGB(255, 119, 119, 119),
          ),
          prefixIcon: Icon(icon, color: Colors.redAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
          ),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required.';
              }
              return null;
            },
      ),
    );
  }
}
