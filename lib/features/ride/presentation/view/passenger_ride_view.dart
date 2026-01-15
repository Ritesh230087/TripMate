import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/chat/presentation/view/chat_view.dart';
import 'package:tripmate/features/ride/presentation/view/rating_feedback_view.dart';
import 'package:tripmate/features/ride/presentation/view/ride_cancellation_view.dart';
import 'package:tripmate/features/ride/presentation/view/passenger_payment.dart';

class PassengerRideProgressView extends StatefulWidget {
  final RideEntity ride;
  final String currentUserId;
  const PassengerRideProgressView({
    super.key,
    required this.ride,
    required this.currentUserId,
  });

  @override
  State<PassengerRideProgressView> createState() => _PassengerRideProgressViewState();
}

class _PassengerRideProgressViewState extends State<PassengerRideProgressView> {
  late String _status;
  final SocketService _socket = serviceLocator<SocketService>();
  final MapController _mapController = MapController();

  List<LatLng> _routePoints = [];
  bool _iHaveReachedMeetingPoint = false;
  bool _riderReachedMeetingPoint = false;
  bool _isDashed = false;
  LatLng? _riderLivePosition;

  bool get _isSmartMatch => widget.ride.matchType == 'smart';

  @override
  void initState() {
    super.initState();
    _status = widget.ride.status;
    if (_status == 'arrived') _riderReachedMeetingPoint = true;
    
    _socket.connect();
    _socket.joinRideRoom(widget.ride.id!);

    _setupSocketListeners();
    _fetchCorrectRoute();
  }

  void _setupSocketListeners() {
    _socket.socket.on('status_updated', (data) {
      if (mounted && data['rideId'] == widget.ride.id) {
        setState(() {
          _status = data['status'];
          if (_status == 'arrived') _riderReachedMeetingPoint = true;
          if (_status == 'heading_to_pickup') _riderReachedMeetingPoint = false;
        });

        if (_status == 'completed') {
            _socket.socket.off('status_updated');
  _socket.socket.off('rider_location_updated');
  _socket.socket.off('rider_confirmed_payment');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PassengerCompletionFlow(ride: widget.ride),
            ),
          );
        } else {
          _fetchCorrectRoute();
        }
      }
    });

    _socket.socket.on('rider_location_updated', (data) {
      if (mounted) {
        setState(() {
          _riderLivePosition = LatLng(data['lat'], data['lng']);
        });
        _fetchCorrectRoute();
      }
    });
    
    // Listen for rider acknowledging payment to go to rating
    _socket.socket.on('rider_confirmed_payment', (_) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => RatingFeedbackView(rideId: widget.ride.id!, targetRole: 'rider')
        ));
      }
    });
  }

  @override
  void dispose() {
    _socket.socket.off('status_updated');
    _socket.socket.off('rider_location_updated');
    // _socket.socket.off('rider_confirmed_payment');
    super.dispose();
  }

  Future<void> _fetchCorrectRoute() async {
    LatLng start;
    LatLng end;
    bool dashed = false;

    LatLng pickupMP = widget.ride.pickupMeetingPoint ?? widget.ride.passengerActualPickup!;
    LatLng dropoffMP = widget.ride.dropMeetingPoint ?? widget.ride.toLatLng;
    LatLng passengerHome = widget.ride.passengerActualPickup ?? widget.ride.fromLatLng;

    if (_status == 'ongoing') {
      start = pickupMP;
      end = dropoffMP;
      dashed = false;
    } 
    // Logic: If both are at the meeting point, remove all polylines
    else if (_iHaveReachedMeetingPoint && _riderReachedMeetingPoint) {
      if (mounted) setState(() => _routePoints = []);
      return;
    }
    // Detour Logic: Remove polyline once rider arrives at passenger location
    else if (!_isSmartMatch && _riderReachedMeetingPoint) {
      if (mounted) setState(() => _routePoints = []);
      return;
    }
    else if (_isSmartMatch) {
      if (!_iHaveReachedMeetingPoint) {
        // Passenger still at home or walking
        start = passengerHome;
        end = pickupMP;
        dashed = true;
      } else {
        // Passenger reached meeting point, show Rider's driving line
        start = _riderLivePosition ?? widget.ride.fromLatLng;
        end = pickupMP;
        dashed = false;
      }
    } else {
      // Detour Match: Show Rider to Passenger route from start (booked)
      start = _riderLivePosition ?? widget.ride.fromLatLng;
      end = pickupMP;
      dashed = false;
    }

    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final pts = data['routes'][0]['geometry']['coordinates'] as List;
        if (mounted) {
          setState(() {
            _routePoints = pts.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
            _isDashed = dashed;
          });
        }
      }
    } catch (_) {}
  }

  void _markArrivedAtMeetingPoint() {
  setState(() => _iHaveReachedMeetingPoint = true);
  // This line triggers the socket 'passenger_ready' in index.js
  _socket.socket.emit('passenger_ready', {'rideId': widget.ride.id});
  _fetchCorrectRoute();
}

  String _getStatusPillText() {
    if (_status == 'ongoing') return "RIDE IN PROGRESS";
    
    if (_iHaveReachedMeetingPoint && _riderReachedMeetingPoint) return "LOOK AROUND FOR RIDER";

    if (_isSmartMatch) {
      if (_riderReachedMeetingPoint) return "RIDER IS WAITING AT SPOT";
      if (_iHaveReachedMeetingPoint) return "WAITING FOR RIDER";
      return _status == 'booked' ? "RIDE NOT STARTED" : "HEAD TO PICKUP MEETING POINT";
    } else {
      if (_riderReachedMeetingPoint) return "RIDER ARRIVED AT YOUR LOCATION";
      return _status == 'booked' ? "RIDE NOT STARTED" : "RIDER IS COMING";
    }
  }


// ✅ 1. CONFIRMATION DIALOG (Styled like your screenshot)
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        title: Center(
          child: Text("Cancel Ride?", 
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        content: Text("Are you sure? This affects your reliability score. This action cannot be undone.", 
          textAlign: TextAlign.center, 
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE), // Neutral Grey
                      foregroundColor: const Color(0xFF616161),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("No, Back", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _selectReason(); // Proceed to reason selection
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEAEA), // Light Pink/Red
                      foregroundColor: const Color(0xFFD32F2F), // Dark Red
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Yes, Cancel", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ 2. REASON SELECTION BOTTOM SHEET
  void _selectReason() {
    String? selectedReason;
    final List<String> reasons = [
      "Traffic delay", 
      "Emergency", 
      "Vehicle breakdown", 
      "Passenger not responding", 
      "Other"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
          left: 24, right: 24, top: 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, 
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
              ),
            ),
            const SizedBox(height: 20),
            Text("Reason for cancellation", 
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            const SizedBox(height: 8),
            Text("Please select why you are cancelling this ride.", 
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9F5E9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text("Select a reason"),
              items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => selectedReason = val,
            ),
            
            const SizedBox(height: 25),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), // Your theme brown
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (selectedReason == null) return;
                  try {
                    await serviceLocator<RideRemoteDataSource>().cancelRide(widget.ride.id!, selectedReason!);
                    if (mounted) {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => RideCancelledView(reason: selectedReason!))
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text("Confirm Cancellation", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }










  @override
  Widget build(BuildContext context) {
    LatLng pickupMP = widget.ride.pickupMeetingPoint ?? widget.ride.passengerActualPickup!;
    LatLng dropoffMP = widget.ride.dropMeetingPoint ?? widget.ride.toLatLng;
    LatLng passengerHome = widget.ride.passengerActualPickup ?? widget.ride.fromLatLng;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: pickupMP, initialZoom: 15),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              if (_routePoints.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _routePoints, 
                    color: _isDashed ? const Color(0xFF8B4513) : Colors.blue, 
                    strokeWidth: 5,
                    pattern: _isDashed ? StrokePattern.dashed(segments: [10, 10]) : const StrokePattern.solid(),
                  ),
                ]),
              MarkerLayer(
                markers: [
                  if (!_isSmartMatch || _riderReachedMeetingPoint || _iHaveReachedMeetingPoint)
                    Marker(
                      point: _riderReachedMeetingPoint || _status == 'ongoing' ? pickupMP : (_riderLivePosition ?? widget.ride.fromLatLng),
                      child: const Icon(Icons.two_wheeler, color: Color(0xFF6D3F1E), size: 40),
                    ),
                  
                  if ((!_isSmartMatch && !_riderReachedMeetingPoint) || 
                      (_isSmartMatch && !(_iHaveReachedMeetingPoint && _riderReachedMeetingPoint)))
                    Marker(
                      point: _iHaveReachedMeetingPoint ? pickupMP : passengerHome,
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFF8B4513), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                        width: 22, height: 22,
                      ),
                    ),
                  if (_isSmartMatch && !_riderReachedMeetingPoint && !_iHaveReachedMeetingPoint)
                    Marker(point: pickupMP, child: const Icon(Icons.location_on, color: Colors.red, size: 35)),
                  
                  // --- DROP-OFF PIN ---
                  if (_status == 'ongoing')
                    Marker(point: dropoffMP, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
                ],
              ),
            ],
          ),

          // Status Pill
          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _status == 'ongoing' ? Colors.green : Colors.orange),
                  const SizedBox(width: 8),
                  Text(_getStatusPillText(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundImage: NetworkImage("${ApiEndpoints.imageUrl}${widget.ride.riderImage?.replaceAll(r'\', '/')}")),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.ride.riderName ?? "Rider", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.star_border, color: Colors.brown, size: 16),
                              Text(" ${widget.ride.riderRating.toStringAsFixed(1)}", style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 15),
                              const Icon(Icons.phone_outlined, color: Colors.grey, size: 15),
                              Text(" ${widget.ride.riderPhone ?? ""}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            ]),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatView(rideId: widget.ride.id!, currentUserId: widget.currentUserId, otherUserName: widget.ride.riderName ?? "Rider", otherUserImage: widget.ride.riderImage,))),
                        child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFF268F76), shape: BoxShape.circle), child: const Icon(Icons.chat_bubble, color: Colors.white, size: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text("${widget.ride.vehicleModel ?? "Vehicle"} - ${widget.ride.vehiclePlateNumber ?? ""}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  //     Text("Rs ${widget.ride.price.toInt()}", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF6D3F1E))),
                  //   ],
                  // ),
                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bike Model Row
          Row(
            children: [
              Text(
                "Bike Model: ",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.ride.vehicleModel ?? "Not Available",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Plate Number Row
          Row(
            children: [
              Text(
                "Plate Number: ",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.ride.vehiclePlateNumber ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    // Price
    Text(
      "Rs ${widget.ride.price.toInt()}",
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF6D3F1E),
      ),
    ),
  ],
),
                  const Divider(height: 30),

                  // Button/Info Logic
                  if (_isSmartMatch && _status != 'booked' && _status != 'ongoing' && !_iHaveReachedMeetingPoint)
                    _actionBtn("I have reached the meeting point", const Color(0xFF268F76), _markArrivedAtMeetingPoint)
                  else if (_status == 'ongoing')
                    _buildInfoBox("Ride in progress - Enjoy!", Colors.green[50]!, Colors.green)
                  else if (_status == 'heading_to_pickup' && !_isSmartMatch)
                    _buildInfoBox("Rider is coming to your location", const Color(0xFFF9F5E9), const Color(0xFF8B4513))
                  else if (_riderReachedMeetingPoint && !_iHaveReachedMeetingPoint)
                    _buildInfoBox("Rider reached your location", const Color(0xFFF9F5E9), const Color(0xFF8B4513))
                  else if (_iHaveReachedMeetingPoint && _riderReachedMeetingPoint)
                    _buildInfoBox("Look around for Rider", const Color(0xFFE0F2F1), const Color(0xFF268F76))
                  else
                    _buildInfoBox(_status == 'booked' ? "Ride not started" : "Wait for the Rider at the meeting point", const Color(0xFFF9F5E9), Colors.grey),
                  if (_status == 'booked')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF9E9E), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Cancel Ride",
                              style: GoogleFonts.inter(color: const Color(0xFFFF5A5A), fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(width: double.infinity, height: 58, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      onPressed: onTap, child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _buildInfoBox(String text, Color bg, Color textCol) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
    );
  }
}