import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/core/payment/esewa_service.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/presentation/view/rating_feedback_view.dart';
import 'payment_status_pages.dart';

class PassengerCompletionFlow extends StatefulWidget {
  final RideEntity ride;
  const PassengerCompletionFlow({super.key, required this.ride});

  @override
  State<PassengerCompletionFlow> createState() => _PassengerCompletionFlowState();
}

class _PassengerCompletionFlowState extends State<PassengerCompletionFlow> {
  final PageController _pageController = PageController();
  final SocketService _socket = serviceLocator<SocketService>();
  String _selectedMethod = 'cash';
  bool _isProcessing = false;
  bool _isNavigating = false;
  bool _listenerSetup = false;

  @override
  void initState() {
    super.initState();
    
    // ✅ CRITICAL: Set up socket connection synchronously first
    _setupSocket();
  }

  void _setupSocket() {
    print('🔌 [PASSENGER] Setting up socket connection...');
    
    // Connect and join room
    _socket.connect();
    _socket.joinRideRoom(widget.ride.id!);
    
    // ✅ Wait a moment for connection to establish, then set up listener
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _listenerSetup) return;
      
      _setupSocketListener();
      _listenerSetup = true;
      print('✅ [PASSENGER] Socket setup complete');
    });
  }

  void _setupSocketListener() {
    // Remove any existing listener
    _socket.socket.off('rider_confirmed_payment');
    
    print('🎧 [PASSENGER] Registering rider_confirmed_payment listener...');
    
    // ✅ Register the listener
    _socket.socket.on('rider_confirmed_payment', (data) {
      print('');
      print('═══════════════════════════════════════');
      print('📦 [PASSENGER] rider_confirmed_payment EVENT RECEIVED!');
      print('📦 Data: $data');
      print('📦 Currently navigating: $_isNavigating');
      print('📦 Currently mounted: $mounted');
      print('═══════════════════════════════════════');
      print('');
      
      // ✅ Prevent double navigation
      if (_isNavigating) {
        print('⚠️ Already navigating, ignoring duplicate event');
        return;
      }

      if (!mounted) {
        print('⚠️ Widget not mounted, cannot navigate');
        return;
      }

      print('🚀 [PASSENGER] Proceeding with navigation to rating page...');
      setState(() => _isNavigating = true);
      
      // ✅ Navigate immediately
      _navigateToRating();
    });
    
    print('✅ [PASSENGER] Listener registered successfully');
    
    // ✅ Test: Listen to ALL socket events for debugging
    _socket.socket.onAny((event, data) {
      print('🔔 [PASSENGER-DEBUG] Event: $event, Data: $data');
    });
  }

  @override
  void dispose() {
    _socket.socket.off('rider_confirmed_payment');
    _socket.socket.offAny();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToRating() {
    print('🚀 [PASSENGER] Executing navigation to rating page');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RatingFeedbackView(
          rideId: widget.ride.id!,
          targetRole: 'rider',
        ),
      ),
    );
  }

  void _jumpToPage(int page) {
    if (mounted && !_isNavigating) {
      _pageController.jumpToPage(page);
    }
  }

  void _handlePaymentTrigger() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    if (_selectedMethod == 'esewa') {
      EsewaService.pay(
        productId: widget.ride.id!,
        productName: "TripMate Payment",
        amount: widget.ride.price,
        onSuccess: (result) async {
          await serviceLocator<RideRemoteDataSource>().processPayment(
            rideId: widget.ride.id!,
            method: 'esewa',
            transactionId: result.refId,
          );
          _socket.emitPaymentConfirmed(widget.ride.id!);
          setState(() => _isProcessing = false);
          _jumpToPage(1); 
        },
        onFailure: () {
          setState(() => _isProcessing = false);
          _jumpToPage(2); 
        },
      );
    } else {
      // Cash Logic
      try {
        await serviceLocator<RideRemoteDataSource>().processPayment(
          rideId: widget.ride.id!,
          method: 'cash'
        );
        print('💵 [PASSENGER] Cash payment processed, emitting payment_initiated');
        _socket.emitPaymentInitiated(widget.ride.id!, "cash");
        setState(() => _isProcessing = false);
        
        // ✅ Jump to waiting page - listener is already active
        _jumpToPage(3);
        print('✅ [PASSENGER] Now on cash waiting page, listener is active');
      } catch (e) {
        print('❌ Error processing cash payment: $e');
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isNavigating,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F5E9),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildMethodSelection(),
            EsewaPaymentSuccessPage(onNext: _navigateToRating),
            EsewaPaymentFailedPage(onRetry: () => _jumpToPage(0)),
            _buildCashWaitingPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelection() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00A884), size: 80),
            const SizedBox(height: 16),
            Text("Ride Completed!", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFAF3E0), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Fare"),
                  Text("Rs ${widget.ride.price.toInt()}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(children: [
              _methodTile("Cash", Icons.payments_outlined, 'cash'),
              const SizedBox(width: 12),
              _methodTile("eSewa", null, 'esewa', imagePath: 'assets/images/esewa_logo.png')
            ]),
            const SizedBox(height: 30),
            _isProcessing 
              ? const CircularProgressIndicator(color: Color(0xFF00A884))
              : _btn("Continue", const Color(0xFF00A884), _handlePaymentTrigger),
          ],
        ),
      ),
    );
  }

  Widget _buildCashWaitingPage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF8B4513)),
            const SizedBox(height: 24),
            Text("Waiting for Rider", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Please pay Rs ${widget.ride.price.toInt()} in cash to the rider",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text("Waiting for rider to confirm receipt...",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // ✅ Debug info for testing
            if (_listenerSetup)
              Container(
                // padding: const EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   color: Colors.green[50],
                //   borderRadius: BorderRadius.circular(8),
                // ),
                // child: Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                //     const SizedBox(width: 8),
                //     // Text(
                //     //   'Listener Active',
                //     //   style: TextStyle(fontSize: 10, color: Colors.green[700]),
                //     // ),
                //   ],
                // ),
              ),
          ],
        ),
      ),
    );
  }

Widget _methodTile(String label, IconData? icon, String method, {String? imagePath}) {
  bool selected = _selectedMethod == method;
  return Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF00A884) : Colors.grey[200]!, 
            width: 2
          ),
          color: selected ? const Color(0xFFE0F2F1) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image/Icon container with fixed height for consistency
            SizedBox(
              height: 40,
              child: imagePath != null 
                ? Image.asset(
                    imagePath, 
                    height: 40,
                    fit: BoxFit.contain, // ✅ This maintains aspect ratio
                    errorBuilder: (c, e, s) => Icon(
                      Icons.wallet,
                      size: 32,
                      color: selected ? const Color(0xFF00A884) : Colors.grey,
                    ),
                  )
                : Icon(
                    icon, 
                    size: 32, // ✅ Increased from default size
                    color: selected ? const Color(0xFF00A884) : Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: selected ? const Color(0xFF00A884) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _btn(String label, Color color, VoidCallback onTap) => SizedBox(
    width: double.infinity, height: 55, 
    child: ElevatedButton(
      onPressed: _isNavigating ? null : onTap, 
      style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), 
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
    )
  );
}