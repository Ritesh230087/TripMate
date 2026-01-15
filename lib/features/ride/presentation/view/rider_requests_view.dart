import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart'; // ✅ Import your custom snackbar
import 'package:tripmate/features/ride/domain/entity/ride_request_entity.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_request_bloc.dart';

class RiderRequestsView extends StatelessWidget {
  const RiderRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<RiderRequestBloc>()..add(LoadRiderRequestsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F5E9),
        appBar: AppBar(
          title: Text("Ride Requests",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: const Color(0xFFF9F5E9),
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
                onPressed: () => Navigator.pop(context)),
          ),
        ),
        body: BlocListener<RiderRequestBloc, RiderRequestState>(
          // ✅ LISTENER FOR SUCCESS/ERROR SNACKBARS
          listener: (context, state) {
            if (state.isSuccess) {
              showMySnackBar(
                context: context,
                message: "Request processed successfully!",
                color: const Color(0xFF268F76),
              );
            }
            if (state.error != null) {
              showMySnackBar(
                context: context,
                message: state.error!,
                isError: true,
              );
            }
          },
          child: BlocBuilder<RiderRequestBloc, RiderRequestState>(
            builder: (context, state) {
              if (state.isLoading && state.requests.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B4513)));
              }
              if (state.requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_email_read_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("No incoming requests.",
                          style: GoogleFonts.inter(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => context
                    .read<RiderRequestBloc>()
                    .add(LoadRiderRequestsEvent()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.requests.length,
                  itemBuilder: (context, index) =>
                      _buildRequestCard(context, state.requests[index]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RideRequestEntity req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8D5C4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP SECTION: Passenger Info
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF9F5E9),
                backgroundImage: req.passengerImage.isNotEmpty
                    ? NetworkImage(
                        "${ApiEndpoints.imageUrl}${req.passengerImage.replaceAll(r'\', '/')}")
                    : null,
                child:
                    req.passengerImage.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.passengerName,
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(" ${req.passengerRating.toStringAsFixed(1)}",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // ✅ PASSENGER TAGS: Styled exactly like vehicle model tags
                    if (req.passengerTags != null && req.passengerTags!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 4,
                          children: req.passengerTags!.take(2).map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1), // Light Teal
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF00796B),
                                  fontWeight: FontWeight.bold),
                            ),
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Rs ${req.price.toInt()}",
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF8B4513))),
                  Text("${req.date}",
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  Text("${req.time}",
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const Divider(height: 32),

          // 2. MIDDLE SECTION: Route Details
          Stack(
            children: [
              Positioned(
                  left: 5,
                  top: 10,
                  bottom: 10,
                  width: 1,
                  child: Container(color: Colors.grey.shade300)),
              Column(
                children: [
                  _routeRow(Icons.circle, Colors.grey, "PICKUP FROM",
                      req.fromLocation, req.pickupDetour, req.pickupWalk),
                  const SizedBox(height: 24),
                  _routeRow(Icons.location_on, const Color(0xFF8B4513),
                      "DROP OFF AT", req.toLocation, req.dropoffDetour, req.dropoffWalk),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // 3. BOTTOM SECTION: Action Buttons
          Row(
            children: [
              Expanded(
                  child: _btn("Decline", const Color(0xFFF5F2EA),
                      const Color(0xFFA65A49), () {
                context.read<RiderRequestBloc>().add(RejectRequestEvent(req.id));
              })),
              const SizedBox(width: 16),
              Expanded(
                  child: _btn("Accept", const Color(0xFF268F76), Colors.white, () {
                context.read<RiderRequestBloc>().add(AcceptRequestEvent(req.id));
              })),
            ],
          )
        ],
      ),
    );
  }

  Widget _routeRow(IconData icon, Color iconCol, String label, String loc,
      int detour, int walk) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: iconCol),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              Text(loc,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              if (detour > 0)
                _buildRouteAlert(Icons.alt_route, Colors.orange,
                    "Requires $detour m rider detour"),
              if (walk > 0)
                _buildRouteAlert(Icons.directions_walk, Colors.blue,
                    "Passenger walks $walk m to you"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteAlert(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _btn(String t, Color bg, Color text, VoidCallback onTap) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: text,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 0)),
        child: Text(t,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}