import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripmate/core/network/os_location_service.dart';
import 'package:tripmate/features/ride/presentation/view/location_search_view.dart';
import 'package:tripmate/features/ride/presentation/view/available_rides_view.dart';

class PlanRideView extends StatefulWidget {
  const PlanRideView({super.key});

  @override
  State<PlanRideView> createState() => _PlanRideViewState();
}

class _PlanRideViewState extends State<PlanRideView> {
  // Controllers
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Logic & State
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  final OSLocationService _locationService = OSLocationService();

  // Colors
  final Color brownColor = const Color(0xFF8B4513);
  final Color beigeBg = const Color(0xFFF9F5E9);
  final Color lightGreyInput = const Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    _pickupController.text = "Fetching location...";
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String address = await _locationService.getAddressFromLatLng(position.latitude, position.longitude);
      
      if(mounted) {
        setState(() {
          _pickupLatLng = LatLng(position.latitude, position.longitude);
          _pickupController.text = address; 
        });
      }
    } catch (e) {
      if(mounted) setState(() => _pickupController.text = "Tap to select pickup");
    }
  }

  void _openSearch(String title, bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchView(
          title: title,
          initialLocation: isPickup ? _pickupLatLng : _dropoffLatLng,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        if (isPickup) {
          _pickupController.text = result['address'];
          _pickupLatLng = result['latlng'];
        } else {
          _dropoffController.text = result['address'];
          _dropoffLatLng = result['latlng'];
        }
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      // lastDate: DateTime(2026),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: brownColor, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked); // Format matching backend
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: brownColor, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeBg,
      appBar: AppBar(
        backgroundColor: beigeBg,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text("Plan Ride", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- ROUTE CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Route", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  
                  _label("Pickup Location"),
                  _buildTapField(
                    controller: _pickupController,
                    icon: Icons.my_location,
                    iconColor: brownColor,
                    hint: "Select Pickup",
                    onTap: () => _openSearch("Select Pickup", true),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _label("Drop-off Location"),
                  _buildTapField(
                    controller: _dropoffController,
                    icon: Icons.location_on,
                    iconColor: Colors.redAccent,
                    hint: "Select Drop-off",
                    onTap: () => _openSearch("Select Drop-off", false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- SCHEDULE CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Schedule", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  _label("Date"),
                  _buildTapField(
                    controller: _dateController,
                    hint: "yyyy-MM-dd",
                    icon: Icons.calendar_today_outlined, // Left Icon
                    iconColor: const Color(0xFFD2B48C),
                    onTap: _selectDate,
                    suffixIcon: Icons.calendar_month, // ✅ Right Icon
                  ),

                  const SizedBox(height: 16),

                  _label("Time"),
                  _buildTapField(
                    controller: _timeController,
                    hint: "HH:mm",
                    icon: Icons.access_time, // Left Icon
                    iconColor: const Color(0xFFD2B48C),
                    onTap: _selectTime,
                    suffixIcon: Icons.access_time_filled, // ✅ Right Icon
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: beigeBg,
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_pickupLatLng == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a pickup location.")));
                return;
              }
              if (_dropoffLatLng == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a drop-off location.")));
                return;
              }
              if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select date and time.")));
                return;
              }
              
              // ✅ Navigate to Available Rides Screen with Params
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvailableRidesView(
                    destination: _dropoffController.text,
                    pickupLat: _pickupLatLng!.latitude,
                    pickupLng: _pickupLatLng!.longitude,
                    dropoffLat: _dropoffLatLng!.latitude,
                    dropoffLng: _dropoffLatLng!.longitude,
                    date: _dateController.text,
                    searchTime: _timeController.text, 
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: brownColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text("Find Ride", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // Updated Widget to support Suffix Icon
  Widget _buildTapField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required VoidCallback onTap,
    IconData? suffixIcon, 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: lightGreyInput, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: controller.text.isEmpty ? Colors.grey[400] : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ✅ Display Suffix Icon if provided
            if (suffixIcon != null) ...[
              const SizedBox(width: 10),
              Icon(suffixIcon, color: const Color(0xFFD2B48C), size: 20),
            ]
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)));
}