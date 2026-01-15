import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tripmate/app/constant/api_endpoints.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  IO.Socket get socket {
    if (_socket == null) {
      connect();
    }
    return _socket!;
  }

  void connect() {
    if (_socket != null && _socket!.connected) {
      print('✅ Socket already connected');
      return;
    }

    String url = ApiEndpoints.imageUrl;
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    print('🔌 Connecting to socket: $url');

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ SOCKET CONNECTED to $url');
      print('✅ Socket ID: ${_socket!.id}');
    });
    
    _socket!.onDisconnect((_) => print('❌ SOCKET DISCONNECTED'));
    _socket!.onConnectError((err) => print('⚠️ SOCKET ERROR: $err'));
    _socket!.onError((err) => print('⚠️ SOCKET ERROR: $err'));
  }

  // --- ROOM MANAGEMENT ---
  void joinRideRoom(String rideId) {
    print('📍 Attempting to join room: $rideId');
    socket.emit('join_room', rideId);
    print('✅ Emitted join_room for: $rideId');
  }

  // --- CHAT MESSAGING ---
  void sendMessage(String rideId, String senderId, String message, String senderName) {
    socket.emit('send_message', {
      'rideId': rideId,
      'senderId': senderId,
      'message': message,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // --- PASSENGER PAYMENT EMITS ---
  void emitPaymentInitiated(String rideId, String method) {
    print('💵 [PASSENGER] Emitting payment_initiated: $rideId, $method');
    socket.emit('payment_initiated', {
      'rideId': rideId,
      'method': method,
    });
  }

  void emitPaymentConfirmed(String rideId) {
    print('✅ [PASSENGER] Emitting payment_confirmed: $rideId');
    socket.emit('payment_confirmed', {
      'rideId': rideId,
      'status': 'paid',
      'method': 'esewa',
    });
  }

  // --- RIDER PAYMENT EMITS ---
  void emitRiderConfirmed(String rideId) {
    print('✅ [RIDER] Emitting rider_confirmed_payment: $rideId');
    socket.emit('rider_confirmed_payment', {
      'rideId': rideId,
      'status': 'paid'
    });
  }

  // --- PASSENGER READY STATUS ---
  void emitPassengerReady(String rideId) {
    socket.emit('passenger_ready', {
      'rideId': rideId,
    });
  }
  

  // --- CLEANUP ---
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
  }
}