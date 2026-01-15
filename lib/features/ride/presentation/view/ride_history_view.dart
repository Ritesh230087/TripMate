import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/widgets/custom_side_menu.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';

class RideHistoryView extends StatefulWidget {
  final bool isRider; // true for Rider, false for Passenger
  const RideHistoryView({super.key, required this.isRider});

  @override
  State<RideHistoryView> createState() => _RideHistoryViewState();
}

class _RideHistoryViewState extends State<RideHistoryView> {
  late Future<List<RideEntity>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final dataSource = serviceLocator<RideRemoteDataSource>();
    setState(() {
      _historyFuture = widget.isRider 
          ? dataSource.getRiderHistory() 
          : dataSource.getPassengerHistory();
    });
  }

  String _formatDisplayDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now(); 
      if (DateUtils.isSameDay(date, now)) return "TODAY";
      if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) return "YESTERDAY";
      return DateFormat('MMM d, yyyy').format(date).toUpperCase();
    } catch (e) {
      return dateStr.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9), // Cream background
      // Keeps the drawer defined even if we use a back arrow to open the page
      drawer: CustomSideMenu(isRiderMode: widget.isRider), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 72,
        title: Text(
          "Ride History",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            fontSize: 20,
          ),
        ),
        // --- Circular Back Arrow Button ---
        leading: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Go back to previous screen
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back, // Changed from Icons.menu
                  color: Color(0xFF8B4513), // App Brown
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35), 
            topRight: Radius.circular(35),
          ),
        ),
        child: FutureBuilder<List<RideEntity>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No trips found in history", 
                  style: GoogleFonts.inter(color: Colors.grey)
                )
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => _buildHistoryCard(snapshot.data![index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(RideEntity ride) {
    bool isCompleted = ride.status == 'completed';
    bool isCancelled = ride.status == 'cancelled';
    bool isEsewa = ride.paymentMethod.toLowerCase() == 'esewa';
    
    const Color appBrown = Color(0xFF8B4513);
    Color statusColor = isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    Color statusBg = isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _formatDisplayDate(ride.date),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      ride.time,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ride.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    color: statusColor
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFFBDBDBD)),
                  Container(height: 25, width: 1.2, color: Colors.grey[200]),
                  const Icon(Icons.location_on_rounded, size: 12, color: Colors.redAccent),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.from, 
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 18),
                    Text(ride.to, 
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isCancelled) ...[
                    if (isEsewa)
                      SizedBox(
                        width: 100,
                        height: 20,
                        child: Image.asset(
                          'assets/images/esewa_logo.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payments_outlined, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            "Cash",
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    "Rs ${ride.price.toInt()}",
                    style: GoogleFonts.inter(
                      fontSize: 22, 
                      fontWeight: FontWeight.w900, 
                      color: appBrown,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}