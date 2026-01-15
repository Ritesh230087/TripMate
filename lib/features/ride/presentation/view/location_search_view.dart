import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripmate/core/network/os_location_service.dart';
import 'package:tripmate/features/ride/presentation/view/map_picker_view.dart';

class LocationSearchView extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;

  const LocationSearchView({super.key, required this.title, this.initialLocation});

  @override
  State<LocationSearchView> createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends State<LocationSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final OSLocationService _locationService = OSLocationService();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length > 2) {
        var results = await _locationService.searchPlaces(query);
        if(mounted) {
          setState(() {
            _suggestions = results;
          });
        }
      } else {
        if(mounted) setState(() => _suggestions = []);
      }
    });
  }

  void _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerView(
          initialLocation: widget.initialLocation ?? const LatLng(27.7172, 85.3240)
        ),
      ),
    );

    if (result != null && result is Map) {
      _returnLocation(result['address'], result['latlng']);
    }
  }

  void _returnLocation(String address, LatLng latLng) {
    Navigator.pop(context, {'address': address, 'latlng': latLng});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Enter location...",
                hintStyle: GoogleFonts.inter(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _suggestions = []);
                      },
                    ) 
                  : null,
              ),
            ),
          ),

          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF9F5E9),
                    child: Icon(Icons.map, color: Color(0xFF8B4513)),
                  ),
                  title: Text("Set location on map", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  onTap: _openMapPicker,
                ),
                
                const Divider(),

                if (_suggestions.isEmpty && _searchController.text.length > 2)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No results found", style: GoogleFonts.inter(color: Colors.grey), textAlign: TextAlign.center),
                  ),

                ..._suggestions.map((place) {
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                    title: Text(
                      place['display_name'].split(',')[0], 
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      place['display_name'], 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      final lat = double.parse(place['lat']);
                      final lon = double.parse(place['lon']);
                      _returnLocation(place['display_name'].split(',')[0], LatLng(lat, lon));
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}