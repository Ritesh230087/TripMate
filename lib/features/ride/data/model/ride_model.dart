import 'package:latlong2/latlong.dart';
import '../../domain/entity/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    super.id, required super.riderId, required super.from, required super.fromLatLng,
    required super.to, required super.toLatLng, required super.date, required super.time,
    required super.price, super.riderName, super.riderImage, super.vehicleName,
    super.riderRating, super.riderTags, required super.status, 
    super.pickupMeetingPoint, super.dropMeetingPoint, 
    super.passengerActualPickup, super.passengerActualDropoff,
    super.paymentMethod, super.paymentStatus,
    super.matchType, super.pickupDetour, super.pickupWalk, super.dropoffDetour,
    super.dropoffWalk, super.totalDetour, super.totalWalk, super.routePath,
    super.acceptedPassengerName, super.acceptedPassengerImage, super.acceptedPassengerPhone,
    super.riderPhone, super.vehiclePlateNumber, super.vehicleModel,
    super.isBooked,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    LatLng parseLatLng(dynamic coord) {
      if (coord == null || coord['lat'] == null || coord['lng'] == null) {
        return const LatLng(0, 0); // Safe fallback
      }
      return LatLng(double.parse(coord['lat'].toString()), double.parse(coord['lng'].toString()));
    }

    final dynamic riderRaw = json['rider'];
    final bool isRiderPopulated = riderRaw is Map;
    final Map<String, dynamic> riderData = isRiderPopulated ? riderRaw as Map<String, dynamic> : {};
    


    List<String> extractedTags = [];
  if (json['riderTags'] != null && (json['riderTags'] as List).isNotEmpty) {
    extractedTags = List<String>.from(json['riderTags']);
  } else if (riderData['riderFeedbackTags'] != null) {
    extractedTags = List<String>.from(riderData['riderFeedbackTags']);
  }


    final Map<String, dynamic> kyc = riderData['kycDetails'] ?? {};

    final List? passengerList = json['passengers'] as List?;
    final bool isPassengerPopulated = passengerList != null && passengerList.isNotEmpty && passengerList[0] is Map;
    final firstPassenger = isPassengerPopulated ? passengerList[0] as Map<String, dynamic> : {};

    return RideModel(
      id: json['_id']?.toString(),
      riderId: isRiderPopulated ? (riderData['_id'] ?? '').toString() : (riderRaw?.toString() ?? ''),
      from: json['fromLocation'] ?? 'Unknown Start',
      fromLatLng: parseLatLng(json['fromLatLng']),
      to: json['toLocation'] ?? 'Unknown End',
      toLatLng: parseLatLng(json['toLatLng']),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? 'booked',
      paymentMethod: json['paymentMethod'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      riderName: riderData['fullName'] ?? "Rider",
      riderImage: riderData['profilePic'],
      riderPhone: riderData['phone'],
      riderRating: (json['riderRating'] as num?)?.toDouble() ?? (riderData['riderRating'] as num?)?.toDouble() ?? 5.0,
      riderTags: extractedTags,
      // riderTags: json['riderTags'] != null ? List<String>.from(json['riderTags']) : [],
      vehicleName: kyc['vehicleModel'] ?? "Vehicle",
      vehicleModel: kyc['vehicleModel'],
      vehiclePlateNumber: kyc['vehiclePlateNumber'],
      matchType: json['matchType'] ?? 'detour',
      pickupDetour: (json['pickupDetour'] as num?)?.toInt() ?? 0,
      pickupWalk: (json['pickupWalk'] as num?)?.toInt() ?? 0,
      dropoffDetour: (json['dropoffDetour'] as num?)?.toInt() ?? 0,
      dropoffWalk: (json['dropoffWalk'] as num?)?.toInt() ?? 0,
      pickupMeetingPoint: parseLatLng(json['pickupMeetingPoint']),
      dropMeetingPoint: parseLatLng(json['dropMeetingPoint']),
      passengerActualPickup: parseLatLng(json['passengerActualPickup']),
      passengerActualDropoff: parseLatLng(json['passengerActualDropoff']),
      isBooked: passengerList?.isNotEmpty ?? false,
      acceptedPassengerName: firstPassenger['fullName'],
      acceptedPassengerImage: firstPassenger['profilePic'],
      acceptedPassengerPhone: firstPassenger['phone'],
    );
  }
}