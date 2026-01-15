import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/core/network/socket_service.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/presentation/view/rating_feedback_view.dart';

class RiderPaymentConfirmationView extends StatefulWidget {
  final RideEntity ride;
  const RiderPaymentConfirmationView({super.key, required this.ride});

  @override
  State<RiderPaymentConfirmationView> createState() => _RiderPaymentConfirmationViewState();
}

class _RiderPaymentConfirmationViewState extends State<RiderPaymentConfirmationView> {
  final SocketService _socket = serviceLocator<SocketService>();
  String _paymentStatus = "waiting"; 
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _socket.connect();
    _socket.joinRideRoom(widget.ride.id!);

    _socket.socket.on('payment_confirmed', _handlePaymentConfirmed);
    _socket.socket.on('payment_initiated', _handlePaymentInitiated);
  }

  void _handlePaymentConfirmed(dynamic data) {
    if (_isNavigating) return;
    
    if (mounted) {
      setState(() => _paymentStatus = "esewa_done");
    }
  }

  void _handlePaymentInitiated(dynamic data) {
    // ✅ CRITICAL: Ignore if we're already navigating
    if (_isNavigating) return;
    
    if (mounted && data['method'] == 'cash') {
      setState(() => _paymentStatus = "cash_selected");
    }
  }

  Future<void> _handleRiderAcknowledge(bool isCash) async {
    // ✅ Prevent multiple clicks
    if (_isNavigating) return;

    // ✅ Lock navigation FIRST (before ANY async operations)
    setState(() {
      _isNavigating = true;
    });

    // ✅ Remove listeners IMMEDIATELY to prevent re-triggering
    _socket.socket.off('payment_confirmed');
    _socket.socket.off('payment_initiated');

    try {
      if (isCash) {
        // Update payment status in DB
        await serviceLocator<RideRemoteDataSource>().confirmPayment(widget.ride.id!);
      }
      
      // Notify Passenger - but we won't listen to our own emission
      _socket.emitRiderConfirmed(widget.ride.id!);

      // ✅ Ensure socket message is sent before navigation
      await Future.delayed(const Duration(milliseconds: 150));

      // Navigate
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RatingFeedbackView(
              rideId: widget.ride.id!, 
              targetRole: 'passenger'
            ),
          ),
        );
      }
    } catch (e) {
      // Only re-attach listeners if there was an error
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
        
        _socket.socket.on('payment_confirmed', _handlePaymentConfirmed);
        _socket.socket.on('payment_initiated', _handlePaymentInitiated);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up listeners
    _socket.socket.off('payment_confirmed');
    _socket.socket.off('payment_initiated');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ Prevent back button during navigation
      body: WillPopScope(
        onWillPop: () async => !_isNavigating,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isNavigating) ..._buildProcessing()
                else if (_paymentStatus == "waiting") ..._buildWaiting()
                else if (_paymentStatus == "esewa_done") ..._buildEsewaDone()
                else ..._buildCashConfirm()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProcessing() => [
    const CircularProgressIndicator(color: Colors.brown),
    const SizedBox(height: 25),
    Text(
      "Processing...", 
      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)
    ),
    const SizedBox(height: 10),
    const Text(
      "Please wait...", 
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey),
    ),
  ];

  List<Widget> _buildWaiting() => [
    const CircularProgressIndicator(color: Colors.brown),
    const SizedBox(height: 25),
    Text(
      "Waiting for Payment", 
      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)
    ),
    const SizedBox(height: 10),
    const Text(
      "Waiting for passenger to complete the transaction...", 
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey),
    ),
  ];

  List<Widget> _buildEsewaDone() => [
    const Icon(Icons.verified, color: Colors.green, size: 100),
    const SizedBox(height: 15),
    Text(
      "Payment Received!", 
      style: GoogleFonts.inter(
        fontSize: 24, 
        fontWeight: FontWeight.bold, 
        color: Colors.green
      )
    ),
    const SizedBox(height: 10),
    Text(
      "Successfully received Rs ${widget.ride.price.toInt()} via eSewa.", 
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 40),
    _btn("Continue to Rating", Colors.green, () => _handleRiderAcknowledge(false)),
  ];

  List<Widget> _buildCashConfirm() => [
    const Icon(Icons.account_balance_wallet, color: Colors.brown, size: 100),
    const SizedBox(height: 15),
    Text(
      "Confirm Cash Payment", 
      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)
    ),
    const SizedBox(height: 10),
    Text(
      "Please collect Rs ${widget.ride.price.toInt()} from the passenger", 
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 40),
    _btn("Confirm Cash Received", Colors.brown, () => _handleRiderAcknowledge(true)),
  ];

  Widget _btn(String label, Color color, VoidCallback onTap) => SizedBox(
    width: double.infinity, 
    height: 55, 
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
      ),
      onPressed: _isNavigating ? null : onTap, // ✅ Disable button during processing
      child: Text(
        label, 
        style: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}