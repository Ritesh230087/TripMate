import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/os_location_service.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart'; // Ensure you import your snackbar helper
import 'package:tripmate/core/widgets/custom_side_menu.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/presentation/view/location_search_view.dart';
import 'package:tripmate/features/ride/presentation/view_model/publish_ride_bloc.dart';

class RiderHomeView extends StatefulWidget {
  const RiderHomeView({super.key});

  @override
  State<RiderHomeView> createState() => _RiderHomeViewState();
}

class _RiderHomeViewState extends State<RiderHomeView> {
  final MapController _mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final TextEditingController _pickupCtrl = TextEditingController(text: "Fetching...");
  final TextEditingController _dropoffCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  
  final OSLocationService _locationService = OSLocationService();
  final Color brown = const Color(0xFF8B4513);
  final Color beige = const Color(0xFFF9F5E9);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String address = await _locationService.getAddressFromLatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _pickupLatLng = LatLng(pos.latitude, pos.longitude);
          _pickupCtrl.text = address;
        });
        _mapController.move(_pickupLatLng!, 15);
      }
    } catch (e) {
      if (mounted) setState(() => _pickupCtrl.text = "Tap to select location");
    }
  }

  void _openSearch(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchView(
          title: isPickup ? "Pick-up Location" : "Destination",
          initialLocation: isPickup ? _pickupLatLng : _dropoffLatLng,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        if (isPickup) {
          _pickupCtrl.text = result['address'];
          _pickupLatLng = result['latlng'];
        } else {
          _dropoffCtrl.text = result['address'];
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
          colorScheme: ColorScheme.light(primary: brown, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: brown, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _timeCtrl.text = picked.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RideBloc>(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const CustomSideMenu(isRiderMode: true),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pickupLatLng ?? const LatLng(27.7172, 85.3240),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tripmate.app',
                ),
                if (_pickupLatLng != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _pickupLatLng!,
                      width: 50, height: 50,
                      child: const Icon(Icons.two_wheeler, color: Color(0xFF8B4513), size: 40),
                    )
                  ]),
              ],
            ),

            Positioned(
              top: 50, left: 20,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: beige,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Icon(Icons.menu, color: brown, size: 28),
                ),
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.55, minChildSize: 0.5, maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: Color(0xFFEEE5DB), child: Icon(Icons.bolt, color: Color(0xFF8B4513))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Share your ride", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              Text("Make new friends on the way", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      _buildInput(_pickupCtrl, Icons.my_location, brown, onTap: () => _openSearch(true)),
                      const SizedBox(height: 16),
                      _buildInput(_dropoffCtrl, Icons.location_on_outlined, Colors.grey, hint: "Where are you heading?", onTap: () => _openSearch(false)),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(child: _buildInput(_timeCtrl, Icons.access_time, const Color(0xFFD2B48C), hint: "--:-- --", onTap: _selectTime)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput(_dateCtrl, Icons.calendar_month, const Color(0xFFD2B48C), hint: "mm/dd/yyyy", onTap: _selectDate)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ✅ PUBLISH SECTION
                      BlocConsumer<RideBloc, RideState>(
                        listener: (context, state) {
                          if (state.isSuccess) {
                            // ✅ SUCCESS SNACKBAR
                            showMySnackBar(
                              context: context, 
                              message: "Ride Published Successfully!"
                            );
                            
                            setState(() {
                              _dropoffCtrl.clear();
                              _dropoffLatLng = null;
                              _dateCtrl.clear();
                              _timeCtrl.clear();
                            });
                          } else if (state.error != null) {
                            // ✅ ERROR SNACKBAR
                            showMySnackBar(
                              context: context, 
                              message: state.error!, 
                              isError: true
                            );
                          }
                        },
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_pickupLatLng == null || _dropoffLatLng == null || _dateCtrl.text.isEmpty || _timeCtrl.text.isEmpty) {
                                  // ✅ VALIDATION SNACKBAR
                                  showMySnackBar(
                                    context: context, 
                                    message: "Please fill all details", 
                                    isError: true
                                  );
                                  return;
                                }
                                
                                context.read<RideBloc>().add(PublishRideEvent(
                                  ride: RideEntity(
                                    riderId: "", 
                                    from: _pickupCtrl.text,
                                    fromLatLng: _pickupLatLng!,
                                    to: _dropoffCtrl.text,
                                    toLatLng: _dropoffLatLng!,
                                    date: _dateCtrl.text,
                                    time: _timeCtrl.text,
                                    price: 150.0,
                                  )
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brown, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                              child: state.isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text("Publish Ride", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, IconData icon, Color color, {String? hint, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
        child: TextField(
          controller: ctrl,
          enabled: false, 
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint, hintStyle: GoogleFonts.inter(color: Colors.grey),
            prefixIcon: Icon(icon, color: color),
            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}