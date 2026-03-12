import 'dart:io';
import 'package:car_rental_app/utils/apptheme/themesettings.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _accelController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _carAvailability = 'Rent';
  File? _mobileImage;
  Uint8List? _webBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() => _webBytes = bytes);
      } else {
        setState(() => _mobileImage = File(image.path));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _hpController.dispose();
    _accelController.dispose();
    _speedController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mobileImage == null && _webBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a car image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Image
      String fileName = "car_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'car_images/$fileName',
      );

      String downloadUrl;
      if (kIsWeb) {
        await storageRef.putData(
          _webBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        await storageRef.putFile(_mobileImage!);
      }
      downloadUrl = await storageRef.getDownloadURL();

      // 2. Data Map - Matching your Home Screen Queries
      final newCarData = {
        "name": _nameController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "rating": double.parse(_ratingController.text.trim()),
        "hp": int.parse(_hpController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        "speed": int.parse(
          _speedController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ),
        "accel": _accelController.text.trim(),
        "availability": _carAvailability,
        "description": _descController.text.trim(),
        "imageUrl": downloadUrl,
        "isFeatured": false,
        "category": "All",
        "userId": FirebaseAuth.instance.currentUser?.uid ?? "guest_user",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // 3. Save to Firestore
      await FirebaseFirestore.instance.collection('cars').add(newCarData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car Posted Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeSettings.isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Post Your Car",
              style: GoogleFonts.poppins(color: ThemeSettings.mainTextColor),
            ),
            centerTitle: true,
            backgroundColor: ThemeSettings.scaffoldColor,
            elevation: 0,
            iconTheme: IconThemeData(color: ThemeSettings.mainTextColor),
          ),
          backgroundColor: ThemeSettings.scaffoldColor,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _buildImagePreview(),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(
                          controller: _nameController,
                          label: "Car Name",
                          icon: Icons.directions_car,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _priceController,
                          label: "Price per Day",
                          icon: Icons.monetization_on,
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _ratingController,
                          label: "Rating (1.0 - 5.0)",
                          icon: Icons.star,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Required';
                            final r = double.tryParse(value);
                            if (r == null || r < 1.0 || r > 5.0)
                              return 'Enter 1.0 to 5.0';
                            return null;
                          },
                          isDark: isDark,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _hpController,
                                label: "HP",
                                icon: Icons.bolt,
                                keyboardType: TextInputType.number,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller: _speedController,
                                label: "Top Speed",
                                icon: Icons.speed,
                                keyboardType: TextInputType.number,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        _buildTextField(
                          controller: _accelController,
                          label: "Acceleration (e.g. 4.2s)",
                          icon: Icons.timer,
                          isDark: isDark,
                        ),
                        _buildTextField(
                          controller: _descController,
                          label: "Description",
                          icon: Icons.description,
                          isDark: isDark,
                        ),
                        _buildAvailabilityDropdown(),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Post Car",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(_webBytes!, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && _mobileImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(_mobileImage!, fit: BoxFit.cover),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
        Text(
          "Upload Car Image",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAvailabilityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Availability",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _carAvailability,
              isExpanded: true,
              items: [
                'Rent',
                'Sale',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _carAvailability = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: ThemeSettings.mainTextColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
          prefixIcon: Icon(icon, color: Colors.redAccent),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          filled: true,
          fillColor: ThemeSettings.cardColor,
        ),
        validator:
            validator ??
            (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
