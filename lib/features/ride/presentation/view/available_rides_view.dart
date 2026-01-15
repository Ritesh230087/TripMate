import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/presentation/view_model/request_bloc.dart';

class AvailableRidesView extends StatefulWidget {
  final String destination;
  final double pickupLat, pickupLng, dropoffLat, dropoffLng;
  final String date;
  final String searchTime;

  const AvailableRidesView({
    super.key,
    required this.destination,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.date,
    required this.searchTime,
  });

  @override
  State<AvailableRidesView> createState() => _AvailableRidesViewState();
}

class _AvailableRidesViewState extends State<AvailableRidesView> {
  late Future<List<RideEntity>> _ridesFuture;
  final ScrollController _timeScrollController = ScrollController();
  List<String> _timeSlots = [];
  int _selectedTimeIndex = 0;
  Set<String> _requestedRideIds = {};

  String _matchTypeFilter = "All"; 
  double _priceMax = 1000.0;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
    _loadInitialData();
  }

  void _generateTimeSlots() {
    List<String> slots = ["All"];
    DateTime baseDate = DateTime(2025, 1, 1, 0, 0);
    for (int i = 0; i < 48; i++) {
      slots.add(DateFormat('h:mm a').format(baseDate));
      baseDate = baseDate.add(const Duration(minutes: 30));
    }
    _timeSlots = slots;
  }

  Future<void> _loadInitialData() async {
    _loadRides();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    try {
      final requests = await serviceLocator<RideRemoteDataSource>().getPassengerRequests();
      setState(() {
        _requestedRideIds = requests
            .where((req) => req['status'] != 'cancelled')
            .map((req) => req['rideId'] is Map ? req['rideId']['_id'].toString() : req['rideId'].toString())
            .toSet();
      });
    } catch (e) { debugPrint("Req Error: $e"); }
  }

  void _loadRides() {
    setState(() {
      _ridesFuture = serviceLocator<RideRemoteDataSource>().searchRides(
          widget.pickupLat, widget.pickupLng, widget.dropoffLat, widget.dropoffLng, widget.date, widget.searchTime);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = _timeSlots.indexWhere((s) => _isWithinSlot(s, widget.searchTime));
      if (index != -1) {
        setState(() => _selectedTimeIndex = index);
        _timeScrollController.animateTo(index * 65.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  bool _isWithinSlot(String slotTime, String rideTime) {
    if (slotTime == "All") return true;
    try {
      DateFormat df = DateFormat('h:mm a');
      DateTime s = df.parse(slotTime);
      DateTime r = df.parse(rideTime);
      return r.isAtSameMomentAs(s) || (r.isAfter(s) && r.difference(s).inMinutes < 30);
    } catch (e) { return false; }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Multi-Filter", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("Match Type", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Row(children: ["All", "Smart", "Detour"].map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(t), selected: _matchTypeFilter == t, onSelected: (v) => setModalState(() => _matchTypeFilter = t)),
              )).toList()),
              const SizedBox(height: 20),
              Text("Max Price: Rs ${_priceMax.toInt()}", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Slider(value: _priceMax, min: 100, max: 1000, divisions: 9, activeColor: const Color(0xFF8B4513), onChanged: (v) => setModalState(() => _priceMax = v)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513)),
                onPressed: () { setState(() {}); Navigator.pop(context); },
                child: const Text("Apply Both Filters", style: TextStyle(color: Colors.white)),
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<RequestBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F5E9),
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)), onPressed: () => Navigator.pop(context)),
          title: Text("Rides to ${widget.destination}", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
          actions: [IconButton(icon: const Icon(Icons.tune, color: Color(0xFF8B4513)), onPressed: _showFilterSheet)],
        ),
        body: Column(children: [
          _buildTimeBar(),
          Expanded(child: _buildList()),
        ]),
      ),
    );
  }

  Widget _buildTimeBar() {
    return Container(
      height: 60, color: Colors.white,
      child: ListView.builder(
        controller: _timeScrollController, scrollDirection: Axis.horizontal,
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          bool sel = _selectedTimeIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: sel ? BoxDecoration(color: const Color(0xFF8B4513), borderRadius: BorderRadius.circular(20)) : null,
              alignment: Alignment.center,
              child: Text(_timeSlots[index], style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<RideEntity>>(
      future: _ridesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No rides available."));

        final rides = snapshot.data!.where((r) {
          bool timeOk = _selectedTimeIndex == 0 || _isWithinSlot(_timeSlots[_selectedTimeIndex], r.time);
          bool typeOk = _matchTypeFilter == "All" || r.matchType?.toLowerCase() == _matchTypeFilter.toLowerCase();
          bool priceOk = r.price <= _priceMax;
          return timeOk && typeOk && priceOk;
        }).toList();

        if (rides.isEmpty) return const Center(child: Text("Change filters to see more rides."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          itemBuilder: (context, index) => _buildCard(rides[index]),
        );
      },
    );
  }

  Widget _buildCard(RideEntity ride) {
    bool requested = _requestedRideIds.contains(ride.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE8D5C4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundImage: ride.riderImage != null ? NetworkImage("${ApiEndpoints.imageUrl}${ride.riderImage!.replaceAll(r'\', '/')}") : null),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ride.riderName ?? "Rider", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                Text(" ${ride.riderRating.toStringAsFixed(1)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(child: Text(ride.vehicleName ?? "Bike", style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          _badge(ride.matchType?.toUpperCase() ?? "DETOUR", ride.matchType == 'smart' ? Colors.purple : Colors.orange),
        ]),

        if (ride.riderTags != null && ride.riderTags!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ride.riderTags!.take(4).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF9F5E9), borderRadius: BorderRadius.circular(6)),
                child: Text(tag, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF8B4513), fontWeight: FontWeight.bold)),
              )).toList(),
            ),
          ),

        const SizedBox(height: 16),
        _routeBox(ride),
        
        // RESTORED: SMART MESSAGES (Detours & Walks)
        if (ride.pickupDetour > 0) 
          _buildAlert(Icons.alt_route, Colors.orange, "Rider detours ${ride.pickupDetour}m to pick you up."),
        
        if (ride.pickupWalk > 0) 
          _buildAlert(Icons.directions_walk, Colors.blue, "Walk ${ride.pickupWalk}m to the meeting point."),

        if (ride.dropoffDetour > 0) 
          _buildAlert(Icons.alt_route, Colors.orange, "Rider detours ${ride.dropoffDetour}m to drop you off."),

        if (ride.dropoffWalk > 0) 
          _buildAlert(Icons.directions_walk, Colors.blue, "Walk ${ride.dropoffWalk}m to final destination."),

        const SizedBox(height: 16),
        _btn(ride, requested),
      ]),
    );
  }

  // RESTORED: Alert Builder for Walks/Detours
  Widget _buildAlert(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: color.withOpacity(0.9), fontWeight: FontWeight.w500))
            )
          ],
        ),
      ),
    );
  }

  Widget _badge(String l, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(l, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: c)),
  );

  Widget _routeBox(RideEntity ride) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ride.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text("${ride.from} → ${ride.to}", style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
        ]),
      ),
      Text("Rs ${ride.price.toInt()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B4513))),
    ]),
  );

  Widget _btn(RideEntity ride, bool req) => BlocConsumer<RequestBloc, RequestState>(
    listener: (context, state) { if (state.isSuccess) { showMySnackBar(context: context, message: "Request Sent!"); _loadUserRequests(); } },
    builder: (context, state) => SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton(
        onPressed: (state.isLoading || req) ? null : () => context.read<RequestBloc>().add(SendRequestEvent(ride: ride, passengerPickupLat: widget.pickupLat, passengerPickupLng: widget.pickupLng, passengerDropoffLat: widget.dropoffLat, passengerDropoffLng: widget.dropoffLng)),
        style: ElevatedButton.styleFrom(backgroundColor: req ? Colors.grey[400] : const Color(0xFF8B4513), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
        child: Text(req ? "Already Requested" : "Send Request", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}