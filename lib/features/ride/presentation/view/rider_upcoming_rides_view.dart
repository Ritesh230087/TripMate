import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/presentation/view/rider_progress_view.dart';

class RiderUpcomingRidesView extends StatefulWidget {
  const RiderUpcomingRidesView({super.key});

  @override
  State<RiderUpcomingRidesView> createState() => _RiderUpcomingRidesViewState();
}

class _RiderUpcomingRidesViewState extends State<RiderUpcomingRidesView> {
  late Future<List<RideEntity>> _myRidesFuture;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  void _loadRides() {
    setState(() {
      _myRidesFuture = serviceLocator<RideRemoteDataSource>().getMyRides();
    });
  }

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
      bool isBooked = ride.isBooked;
      bool isStarted = ['heading_to_pickup', 'arrived', 'ongoing'].contains(ride.status);
      bool isCompleted = ride.status == 'completed';
      bool isPaid = ride.paymentStatus == 'paid';

      if (isCompleted && isPaid) continue;

      if (isStarted || (isCompleted && !isPaid)) {
        grouped["Today"]!.add(ride);
        continue;
      }

      if (!isBooked && now.isAfter(rideStartDateTime.add(const Duration(minutes: 30)))) {
        continue;
      }

      if (DateUtils.isSameDay(rideStartDateTime, now)) {
        grouped["Today"]!.add(ride);
      } else if (DateUtils.isSameDay(rideStartDateTime, now.add(const Duration(days: 1)))) {
        grouped["Tomorrow"]!.add(ride);
      } else if (rideStartDateTime.isAfter(now)) {
        grouped["Later"]!.add(ride);
      }
    }
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  void _showEditDialog(RideEntity ride) {
    String selectedDate = ride.date;
    String selectedTime = ride.time;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF9F5E9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Center(
            child: Text("Edit Ride Schedule",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF8B4513), fontSize: 20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPickerTile(
                label: "DEPARTURE DATE",
                value: selectedDate,
                icon: Icons.calendar_today_rounded,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    builder: (context, child) => _buildPickerTheme(child!),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = DateFormat('yyyy-MM-dd').format(date));
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildPickerTile(
                label: "DEPARTURE TIME",
                value: selectedTime,
                icon: Icons.access_time_rounded,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) => _buildPickerTheme(child!),
                  );
                  if (time != null) {
                    setDialogState(() => selectedTime = time.format(context));
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513)),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await serviceLocator<RideRemoteDataSource>().updateRide(ride.id!, selectedDate, selectedTime, ride.price);
                  if (mounted) {
                    showMySnackBar(context: context, message: "Ride updated successfully!");
                    _loadRides();
                  }
                } catch (e) {
                  if (mounted) {
                    showMySnackBar(context: context, message: e.toString(), isError: true);
                  }
                }
              },
              child: const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String rideId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, // ✅ CHANGED: Full white background
        surfaceTintColor: Colors.white, // ✅ CHANGED: Ensures no tint on Material 3
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Optional: Nicer dialog shape
        title: const Text("Delete Ride?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              // ✅ CHANGED: Border radius 10
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await serviceLocator<RideRemoteDataSource>().deleteRide(rideId);
                if (mounted) {
                  showMySnackBar(context: context, message: "Ride deleted successfully!");
                  _loadRides();
                }
              } catch (e) {
                if (mounted) {
                  showMySnackBar(context: context, message: e.toString(), isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              // ✅ CHANGED: Border radius 10
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8D5C4))),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8B4513), size: 20),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTheme(Widget child) {
    return Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF8B4513))), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      appBar: AppBar(
        title: Text("Upcoming Rides", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<RideEntity>>(
        future: _myRidesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final grouped = _groupAndFilterRides(snapshot.data ?? []);
          if (grouped.isEmpty) return const Center(child: Text("No upcoming rides"));

          return ListView.builder(
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
                  ...grouped[key]!.map((ride) => _buildRideCard(ride)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRideCard(RideEntity ride) {
    bool isBooked = ride.isBooked;
    bool isStarted = ['heading_to_pickup', 'arrived', 'ongoing'].contains(ride.status);
    bool isCompleted = ride.status == 'completed';
    bool paymentPending = ride.paymentStatus != 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
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
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ride.from, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 18),
                Text(ride.to, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [
                    const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(ride.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                  Text(ride.time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(isStarted ? "ONGOING" : (isCompleted ? "WAITING PAYMENT" : (isBooked ? "BOOKED" : "WAITING")),
                      style: TextStyle(color: isStarted ? Colors.blue : (isCompleted ? Colors.red : Colors.orange), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isBooked && !isStarted && !isCompleted)
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                onPressed: () => _showDeleteDialog(ride.id!),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("Delete"),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                onPressed: () => _showEditDialog(ride),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("Edit", style: TextStyle(color: Colors.white)),
              )),
            ])
          else
            _buildActionSection(ride, isCompleted && paymentPending),
        ],
      ),
    );
  }

  Widget _buildActionSection(RideEntity ride, bool pendingPayment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: pendingPayment ? Colors.orange[50] : const Color(0xFFF9F5E9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: ride.acceptedPassengerImage != null
                ? NetworkImage("${ApiEndpoints.imageUrl}${ride.acceptedPassengerImage!.replaceAll(r'\', '/')}")
                : null,
            child: ride.acceptedPassengerImage == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(ride.acceptedPassengerName ?? "Passenger", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiderProgressView(ride: ride))).then((_) => _loadRides()),
            style: ElevatedButton.styleFrom(
                backgroundColor: pendingPayment ? Colors.orange : const Color(0xFF268F76),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(80, 36)),
            child: Text(pendingPayment ? "Confirm" : "Manage", style: const TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }
}