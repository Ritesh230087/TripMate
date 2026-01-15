import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripmate/core/network/os_location_service.dart';

class MapPickerView extends StatefulWidget {
  final LatLng initialLocation;
  const MapPickerView({super.key, required this.initialLocation});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  late final MapController _mapController;
  late LatLng _center;
  final OSLocationService _locationService = OSLocationService();
  String _address = "Fetching location...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = widget.initialLocation;
    _updateAddress(_center);
  }

  // Update address when map drag stops
  Future<void> _updateAddress(LatLng point) async {
    setState(() => _isLoading = true);
    String addr = await _locationService.getAddressFromLatLng(point.latitude, point.longitude);
    if (mounted) {
      setState(() {
        _address = addr;
        _isLoading = false;
        _center = point;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Location", style: GoogleFonts.inter(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation,
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  _center = pos.center;
                }
              },
              onMapEvent: (evt) {
                if (evt is MapEventMoveEnd) {
                  _updateAddress(_mapController.camera.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tripmate.app',
              ),
            ],
          ),
          
          // Fixed Pin in Center
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), // Lift pin tip to center
              child: Icon(Icons.location_on, color: Color(0xFF8B4513), size: 50),
            ),
          ),

          // Confirm Button & Address Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selected Location:", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    _isLoading ? "Loading..." : _address,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        // Return Address and LatLng
                        Navigator.pop(context, {'address': _address, 'latlng': _center});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Confirm Location", style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}