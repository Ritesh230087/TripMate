import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/domain/use_case/send_request_usecase.dart';

abstract class RequestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendRequestEvent extends RequestEvent {
  final RideEntity ride;
  final double passengerPickupLat;
  final double passengerPickupLng;
  final double passengerDropoffLat;
  final double passengerDropoffLng;

  SendRequestEvent({
    required this.ride,
    required this.passengerPickupLat,
    required this.passengerPickupLng,
    required this.passengerDropoffLat,
    required this.passengerDropoffLng,
  });

  @override
  List<Object?> get props => [ride, passengerPickupLat, passengerPickupLng, passengerDropoffLat, passengerDropoffLng];
}

class RequestState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const RequestState({this.isLoading = false, this.isSuccess = false, this.error});

  RequestState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, error];
}

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final SendRequestUseCase _sendRequestUseCase;

  RequestBloc({required SendRequestUseCase sendRequestUseCase}) 
      : _sendRequestUseCase = sendRequestUseCase, 
        super(const RequestState()) {
    on<SendRequestEvent>(_onSendRequest);
  }

  Future<void> _onSendRequest(SendRequestEvent event, Emitter<RequestState> emit) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, error: null));

    final ride = event.ride;
    final meetingLat = ride.pickupMeetingPoint?.latitude ?? event.passengerPickupLat;
    final meetingLng = ride.pickupMeetingPoint?.longitude ?? event.passengerPickupLng;
    final dPointLat = ride.dropMeetingPoint?.latitude ?? event.passengerDropoffLat;
    final dPointLng = ride.dropMeetingPoint?.longitude ?? event.passengerDropoffLng;

    final params = SendRequestParams(
      rideId: ride.id!,
      riderId: ride.riderId,
      meetingPointLat: meetingLat,
      meetingPointLng: meetingLng,
      dropPointLat: dPointLat,
      dropPointLng: dPointLng,
      passengerPickupLat: event.passengerPickupLat,
      passengerPickupLng: event.passengerPickupLng,
      passengerDropoffLat: event.passengerDropoffLat,
      passengerDropoffLng: event.passengerDropoffLng,
      pickupDetour: ride.pickupDetour,
      pickupWalk: ride.pickupWalk,
      dropoffDetour: ride.dropoffDetour,
      dropoffWalk: ride.dropoffWalk,
      matchType: ride.matchType ?? 'detour',
    );

    final result = await _sendRequestUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
    );
  }
}