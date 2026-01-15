import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/core/widgets/custom_side_menu.dart';
import 'package:tripmate/features/home/presentation/view_model/home_view_model.dart';
import 'package:tripmate/features/plan_ride/presentation/view/plan_ride_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MapController _mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 

  @override
  void initState() {
    super.initState();
    context.read<HomeViewModel>().add(LoadCurrentLocationEvent());
    final SocketService socketService = serviceLocator<SocketService>();
    socketService.connect(); 
  }

    @override
  void dispose() {
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Key needed for opening drawer manually
      drawer: const CustomSideMenu(), // ✅ 1. Attach Custom Drawer
      body: Stack(
        children: [
          // --- Map Layer ---
          BlocConsumer<HomeViewModel, HomeState>(
            listener: (context, state) {
              if (state.currentLocation != null) {
                _mapController.move(state.currentLocation!, 15.0);
              }
            },
            builder: (context, state) {
              final LatLng center = state.currentLocation ?? const LatLng(27.7172, 85.3240); // Kathmandu Default
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: center, initialZoom: 15.0),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.tripmate.app',
                  ),
                  if (state.currentLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.currentLocation!,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.my_location, color: Color(0xFF8B4513), size: 40),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),

          // --- Menu Button (Top Left) ---
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(), // ✅ Opens CustomSideMenu
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F5E9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.menu, color: Color(0xFF8B4513), size: 28),
              ),
            ),
          ),

          // --- Bottom Sheet (Search) ---
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    
                    Text("Where to?", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(height: 15),

                    // ✅ Clickable Search Bar -> Opens PlanRideView
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PlanRideView()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black54),
                            const SizedBox(width: 10),
                            Text("Search Destination", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    _buildSavedPlace(Icons.home_outlined, "Home", "Balaju, Kathmandu"),
                    const SizedBox(height: 15),
                    _buildSavedPlace(Icons.work_outline, "Work", "Thamel, Kathmandu"),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlace(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Color(0xFFF9F5E9), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF8B4513), size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
          ],
        )
      ],
    );
  }
}