import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/presentation/view/passenger_payment.dart';
import 'package:tripmate/features/ride/presentation/view/passenger_ride_view.dart';

class PassengerUpcomingRidesView extends StatefulWidget {
  const PassengerUpcomingRidesView({super.key});

  @override
  State<PassengerUpcomingRidesView> createState() => _PassengerUpcomingRidesViewState();
}

class _PassengerUpcomingRidesViewState extends State<PassengerUpcomingRidesView> {
  late Future<List<RideEntity>> _upcomingRidesFuture;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId'); 
    
    setState(() {
      _userId = id;
      _upcomingRidesFuture = serviceLocator<RideRemoteDataSource>().getPassengerUpcomingRides();
    });
  }

  void _refresh() => _loadData();

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      String cleanTime = timeStr.replaceAll('\u202F', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      DateFormat timeFmt = DateFormat("h:mm a"); 
      DateTime time = timeFmt.parse(cleanTime);
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, List<RideEntity>> _groupAndFilterRides(List<RideEntity> rides) {
    Map<String, List<RideEntity>> grouped = {"Today": [], "Tomorrow": [], "Later": []};
    DateTime now = DateTime.now();

    rides.sort((a, b) {
      DateTime dtA = _parseDateTime(a.date, a.time);
      DateTime dtB = _parseDateTime(b.date, b.time);
      return dtA.compareTo(dtB);
    });

    for (var ride in rides) {
      if (ride.status == 'cancelled') continue;
      DateTime rideStartDateTime = _parseDateTime(ride.date, ride.time);
      bool isCompleted = ride.status == 'completed';
      bool isPaid = ride.paymentStatus == 'paid';

      if (isCompleted && isPaid) continue;

      if (DateUtils.isSameDay(rideStartDateTime, now) || rideStartDateTime.isBefore(now)) {
        grouped["Today"]!.add(ride);
      } else if (DateUtils.isSameDay(rideStartDateTime, now.add(const Duration(days: 1)))) {
        grouped["Tomorrow"]!.add(ride);
      } else {
        grouped["Later"]!.add(ride);
      }
    }
    return grouped..removeWhere((k, v) => v.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      appBar: AppBar(
        title: Text("My Trips", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
      ),
      body: _userId == null 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
        : FutureBuilder<List<RideEntity>>(
            future: _upcomingRidesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)));
              }
              final grouped = _groupAndFilterRides(snapshot.data ?? []);
              if (grouped.isEmpty) return const Center(child: Text("No active trips found."));

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    String key = grouped.keys.elementAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                        ),
                        ...grouped[key]!.map((ride) => _buildPassengerCard(ride)),
                      ],
                    );
                  },
                ),
              );
            },
          ),
    );
  }

  Widget _buildPassengerCard(RideEntity ride) {
    bool isCompleted = ride.status == 'completed';
    bool paymentPending = ride.paymentStatus != 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(children: [
                const Icon(Icons.circle, color: Color(0xFF8B4513), size: 10),
                Container(height: 30, width: 2, color: Colors.grey[200]),
                const Icon(Icons.circle, color: Colors.grey, size: 10),
              ]),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ride.from, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 18),
                Text(ride.to, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
              ])),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ride.time, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: isCompleted ? Colors.orange[50] : Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                    child: Text(isCompleted ? "PAYMENT" : ride.status.toUpperCase(), 
                      style: TextStyle(color: isCompleted ? Colors.orange[800] : Colors.blue[800], fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: (isCompleted && paymentPending) ? const Color(0xFFFFF7ED) : const Color(0xFFF9F5E9), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: (ride.riderImage != null && ride.riderImage!.isNotEmpty)
                      ? NetworkImage("${ApiEndpoints.imageUrl}${ride.riderImage!.replaceAll(r'\', '/')}") : null,
                  child: (ride.riderImage == null || ride.riderImage!.isEmpty) ? const Icon(Icons.person, size: 18) : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(ride.riderName ?? "Rider", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ElevatedButton(
                  onPressed: () {
                    if (_userId == null) return;
                    if (isCompleted && paymentPending) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerCompletionFlow(ride: ride))).then((_) => _refresh());
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerRideProgressView(ride: ride, currentUserId: _userId!))).then((_) => _refresh());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isCompleted && paymentPending) ? Colors.orange[600] : const Color(0xFF8B4513),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isCompleted ? "Pay Now" : "View", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}