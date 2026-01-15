import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/widgets/custom_side_menu.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';

class PassengerRequestsView extends StatefulWidget {
  const PassengerRequestsView({super.key});

  @override
  State<PassengerRequestsView> createState() => _PassengerRequestsViewState();
}

class _PassengerRequestsViewState extends State<PassengerRequestsView> {
  late Future<List<dynamic>> _requestsFuture;
  bool _processedViewed = false; // Flag to prevent multiple API calls

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _processedViewed = false;
      _requestsFuture = serviceLocator<RideRemoteDataSource>().getPassengerRequests();
    });
  }

  void _autoMarkAsViewed(List<dynamic> requests) {
    if (_processedViewed) return;

    for (var req in requests) {
      String status = (req['status'] ?? '').toString().toLowerCase();
      if (status == 'rejected' || status == 'expired') {
        serviceLocator<RideRemoteDataSource>().markRequestAsViewed(req['_id']);
      }
    }
    _processedViewed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      drawer: const CustomSideMenu(isRiderMode: false),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 72,
        title: Text(
          "My Requests",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontSize: 20),
        ),
        // --- Updated Leading: Back Button instead of Menu ---
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
                        offset: const Offset(0, 3))
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back, // Changed from Icons.menu
                  color: Color(0xFF8B4513),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B4513)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("No active requests.",
                    style: GoogleFonts.inter(color: Colors.grey)));
          }

          // Automatically mark as viewed so they disappear next time
          _autoMarkAsViewed(snapshot.data!);

          return RefreshIndicator(
            onRefresh: () async => _loadRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  _buildRequestCard(snapshot.data![index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final String status =
        (request['status'] ?? 'pending').toString().toLowerCase();
    final rider = request['riderId'] ?? {};
    final ride = request['rideId'] ?? {};
    final String riderName = rider['fullName'] ?? "Rider";
    final String? riderImg = rider['profilePic'];
    final String from = ride['fromLocation'] ?? "...";
    final String to = ride['toLocation'] ?? "...";
    final String date = ride['date'] ?? "";
    final String time = ride['time'] ?? "";

    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    String statusText;

    if (status == 'accepted') {
      statusColor = const Color(0xFF2E7D32);
      statusBg = const Color(0xFFE8F5E9);
      statusIcon = Icons.check_circle;
      statusText = "Accepted";
    } else if (status == 'rejected') {
      statusColor = const Color(0xFF9B1C1C);
      statusBg = const Color(0xFFFDE8E8);
      statusIcon = Icons.cancel;
      statusText = "Declined";
    } else if (status == 'expired') {
      statusColor = const Color(0xFF6B7280);
      statusBg = const Color(0xFFF3F4F6);
      statusIcon = Icons.history_rounded;
      statusText = "Expired";
    } else {
      statusColor = const Color(0xFF8B4513);
      statusBg = const Color(0xFFFEF7E6);
      statusIcon = Icons.access_time_filled;
      statusText = "Pending";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF9F5E9),
                backgroundImage: riderImg != null
                    ? NetworkImage(
                        "${ApiEndpoints.imageUrl}${riderImg.replaceAll(r'\', '/')}")
                    : null,
                child: riderImg == null
                    ? const Icon(Icons.person,
                        size: 20, color: Color(0xFF8B4513))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(riderName.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1A1A1A))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(statusText,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                  child: Text(from,
                      style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text("→",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold))),
              Flexible(
                  child: Text(to,
                      style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text("$date  |  $time",
                  style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}