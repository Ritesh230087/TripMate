import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/chat/presentation/view/chat_view.dart';
import 'package:tripmate/features/ride/presentation/view/rider_payment%20confirmation_view.dart';
import 'package:tripmate/features/ride/presentation/view/ride_cancellation_view.dart';

class RiderProgressView extends StatefulWidget {
  final RideEntity ride;
  const RiderProgressView({super.key, required this.ride});

  @override
  State<RiderProgressView> createState() => _RiderProgressViewState();
}

class _RiderProgressViewState extends State<RiderProgressView> {
  late String _currentStatus;
  bool _isLoading = false;
  LatLng? _riderLiveGPS;
  List<LatLng> _routePoints = [];
  bool _isDashed = false;
  bool _passengerReachedMeetingPoint = false; 
  bool _riderReachedMeetingPoint = false; 
  final MapController _mapController = MapController();
  final SocketService _socket = serviceLocator<SocketService>();

  bool get _isSmartMatch => widget.ride.matchType == 'smart';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ride.status;
    if (_currentStatus == 'arrived') _riderReachedMeetingPoint = true;

    _socket.connect();
    _socket.joinRideRoom(widget.ride.id!);
    _startLiveTracking();

    _getPolylineFromOSRM();

    _socket.socket.on('status_updated', (data) {
      if (mounted && data['rideId'] == widget.ride.id) {
        setState(() => _currentStatus = data['status']);
        _getPolylineFromOSRM();
      }
    });

    _socket.socket.on('passenger_ready_update', (data) {
      if (mounted) {
        setState(() => _passengerReachedMeetingPoint = true);
        _getPolylineFromOSRM();
      }
    });
  }

  @override
  void dispose() {
    _socket.socket.off('status_updated');
    _socket.socket.off('passenger_ready_update');
    super.dispose();
  }

  void _startLiveTracking() async {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((pos) {
      if (!mounted) return;
      setState(() => _riderLiveGPS = LatLng(pos.latitude, pos.longitude));
      _socket.socket.emit('rider_location_updated', {
        'rideId': widget.ride.id,
        'lat': pos.latitude,
        'lng': pos.longitude
      });
      _getPolylineFromOSRM();
    });
  }

  Future<void> _getPolylineFromOSRM() async {
    LatLng start;
    LatLng end;
    bool dashed = false;

    LatLng riderStartFromDB = widget.ride.fromLatLng;
    LatLng pickupMP = widget.ride.pickupMeetingPoint ?? widget.ride.passengerActualPickup!;
    LatLng dropoffMP = widget.ride.dropMeetingPoint ?? widget.ride.toLatLng;
    LatLng passengerHome = widget.ride.passengerActualPickup ?? widget.ride.fromLatLng;

    if (_currentStatus == 'ongoing') {
      start = pickupMP;
      end = dropoffMP;
      dashed = false;
    } else if (_currentStatus == 'arrived') {
      if (_isSmartMatch && !_passengerReachedMeetingPoint) {
        start = passengerHome;
        end = pickupMP;
        dashed = true;
      } else {
        if (mounted) setState(() => _routePoints = []);
        return;
      }
    } else {
      start = _riderLiveGPS ?? riderStartFromDB;
      end = pickupMP;
      dashed = false;
    }

    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        if (mounted) {
          setState(() {
            _routePoints = coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
            _isDashed = dashed;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _updateStatus(String nextStatus) async {
    setState(() => _isLoading = true);
    try {
      await serviceLocator<RideRemoteDataSource>().updateRideStatus(widget.ride.id!, nextStatus);
      _socket.socket.emit('status_updated', {'rideId': widget.ride.id, 'status': nextStatus});
      
      setState(() {
        _currentStatus = nextStatus;
        if (nextStatus == 'arrived') _riderReachedMeetingPoint = true;
        _isLoading = false;
      });

      if (nextStatus == 'completed') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RiderPaymentConfirmationView(ride: widget.ride)));
      } else {
        _getPolylineFromOSRM();
      }
    } catch (e) {
      setState(() => _isLoading = false);
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






  Widget _btn(String l, Color c, VoidCallback o) => SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: c, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: o, child: Text(l, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));

  @override
  Widget build(BuildContext context) {
    LatLng pickupMP = widget.ride.pickupMeetingPoint ?? widget.ride.passengerActualPickup!;
    LatLng dropoffMP = widget.ride.dropMeetingPoint ?? widget.ride.toLatLng;
    LatLng passengerHome = widget.ride.passengerActualPickup ?? widget.ride.fromLatLng;

    LatLng bikePosition = (_riderReachedMeetingPoint || _currentStatus == 'ongoing') ? pickupMP : (widget.ride.fromLatLng);

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
                    pattern: _isDashed ? StrokePattern.dashed(segments: [10, 10]) : StrokePattern.solid(),
                  ),
                ]),
              MarkerLayer(
                markers: [
                  Marker(
                    point: bikePosition,
                    width: 45, height: 45,
                    child: const Icon(Icons.two_wheeler, color: Color(0xFF6D3F1E), size: 40),
                  ),

                  if (_isSmartMatch && !_passengerReachedMeetingPoint && !_riderReachedMeetingPoint)
                    Marker(
                      point: pickupMP,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 35),
                    ),

if ((!_isSmartMatch && !_riderReachedMeetingPoint) || 
    (_isSmartMatch && _riderReachedMeetingPoint && !_passengerReachedMeetingPoint && _currentStatus != 'ongoing') ||
    (_isSmartMatch && _passengerReachedMeetingPoint && !_riderReachedMeetingPoint))
  Marker(
    point: _passengerReachedMeetingPoint ? pickupMP : (_isSmartMatch ? passengerHome : pickupMP),
    width: 26, height: 26,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
    ),
  ),

                  if (_currentStatus == 'ongoing')
                    Marker(
                      point: dropoffMP,
                      width: 40, height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _currentStatus == 'ongoing' ? Colors.green : Colors.orange),
                  const SizedBox(width: 8),
                  Text(_getStatusPillText(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage("${ApiEndpoints.imageUrl}${widget.ride.acceptedPassengerImage?.replaceAll(r'\', '/')}")),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.ride.acceptedPassengerName ?? "Passenger",
                                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_border, color: Colors.brown, size: 18),
                                const SizedBox(width: 4),
                                Text("4.9", style: GoogleFonts.inter(color: Colors.brown, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 15),
                                const Icon(Icons.phone_outlined, color: Colors.grey, size: 16),
                                const SizedBox(width: 5),
                                Text(widget.ride.acceptedPassengerPhone ?? "", style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatView(rideId: widget.ride.id!, currentUserId: widget.ride.riderId, otherUserName: widget.ride.acceptedPassengerName ?? 'Passenger', otherUserImage: widget.ride.acceptedPassengerImage,))),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Color(0xFF268F76), shape: BoxShape.circle),
                          child: const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Fare", style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                      Text("Rs ${widget.ride.price.toInt()}",
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF6D3F1E))),
                    ],
                  ),
                  const Divider(height: 25),

                  _buildLocationRow(widget.ride.from, widget.ride.to),
                  const SizedBox(height: 25),

                  _buildMainButton(),

                  // CANCEL BUTTON: Styled with red border logic restored
                  if (_currentStatus == 'booked')
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

  String _getStatusPillText() {
    if (_currentStatus == 'ongoing') return "RIDE IN PROGRESS";
    if (_currentStatus == 'arrived') {
      if (_isSmartMatch) {
        if (_passengerReachedMeetingPoint && _riderReachedMeetingPoint) return "LOOK FOR PASSENGER AROUND YOU";
        return _passengerReachedMeetingPoint ? "PASSENGER ARRIVED" : "WAITING FOR PASSENGER";
      }
      return "WAITING FOR PASSENGER";
    }
    if (_currentStatus == 'heading_to_pickup') {
      if (_isSmartMatch && _passengerReachedMeetingPoint) return "PASSENGER IS WAITING";
      return "HEADING TO PICKUP";
    }
    return "RIDE BOOKED";
  }

  Widget _buildMainButton() {
    String label; Color color; IconData icon; VoidCallback onTap;

    if (_currentStatus == 'booked') {
      label = "Going to Pickup"; color = const Color(0xFF6D3F1E); icon = Icons.near_me;
      onTap = () => _updateStatus('heading_to_pickup');
    } else if (_currentStatus == 'heading_to_pickup') {
      label = _isSmartMatch ? "Arrived at meeting point" : "Arrived at Location"; 
      color = const Color(0xFF6D3F1E); icon = Icons.location_on;
      onTap = () => _updateStatus('arrived');
    } else if (_currentStatus == 'arrived') {
      label = "Start Ride"; color = const Color(0xFF268F76); icon = Icons.play_arrow;
      onTap = () => _updateStatus('ongoing');
    } else {
      label = "Complete Ride"; color = const Color(0xFFD32F2F); icon = Icons.check_circle;
      onTap = () => _updateStatus('completed');
    }

    return SizedBox(
      width: double.infinity, height: 58,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
        onPressed: _isLoading ? null : onTap,
        label: Text(label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildLocationRow(String from, String to) {
    return Row(
      children: [
        Column(children: [
          const Icon(Icons.circle, color: Color(0xFF6D3F1E), size: 10),
          Container(height: 25, width: 1, color: Colors.grey[300]),
          const Icon(Icons.circle, color: Colors.grey, size: 10),
        ]),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMarquee(from, true),
              const SizedBox(height: 15),
              _buildMarquee(to, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarquee(String text, bool isBold) {
    return LayoutBuilder(builder: (context, constraints) {
      final span = TextSpan(text: text, style: GoogleFonts.inter(fontSize: 14));
      final tp = TextPainter(text: span, maxLines: 1, textDirection: TextDirection.ltr)..layout(maxWidth: constraints.maxWidth);
      if (tp.didExceedMaxLines) {
        return SizedBox(height: 20, child: Marquee(
          text: text,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          scrollAxis: Axis.horizontal, blankSpace: 50.0, velocity: 30.0,
          pauseAfterRound: const Duration(seconds: 2),
        ));
      }
      return Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis);
    });
  }
}