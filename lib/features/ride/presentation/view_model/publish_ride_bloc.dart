import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/domain/use_case/publish_ride_usecase.dart';

// Events
abstract class RideEvent {}
class PublishRideEvent extends RideEvent {
  final RideEntity ride;
  PublishRideEvent({required this.ride});
}

// States
class RideState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  RideState({this.isLoading = false, this.isSuccess = false, this.error});
}

// Bloc
class RideBloc extends Bloc<RideEvent, RideState> {
  final PublishRideUseCase publishRideUseCase;

  RideBloc(this.publishRideUseCase) : super(RideState()) {
    on<PublishRideEvent>((event, emit) async {
      emit(RideState(isLoading: true));
      final result = await publishRideUseCase(event.ride);
      result.fold(
        (l) => emit(RideState(isLoading: false, error: l.message)),
        (r) => emit(RideState(isLoading: false, isSuccess: true)),
      );
    });
  }
}