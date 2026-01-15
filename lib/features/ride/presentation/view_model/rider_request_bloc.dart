import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_request_entity.dart';

// --- Events ---
abstract class RiderRequestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRiderRequestsEvent extends RiderRequestEvent {}

class AcceptRequestEvent extends RiderRequestEvent {
  final String id;
  AcceptRequestEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class RejectRequestEvent extends RiderRequestEvent {
  final String id;
  RejectRequestEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- States ---
class RiderRequestState extends Equatable {
  final bool isLoading;
  final bool isSuccess; // ✅ Added this
  final List<RideRequestEntity> requests;
  final String? error;

  const RiderRequestState({
    this.isLoading = false,
    this.isSuccess = false, // ✅ Default false
    this.requests = const [],
    this.error,
  });

  // ✅ Added copyWith to handle state updates properly
  RiderRequestState copyWith({
    bool? isLoading,
    bool? isSuccess,
    List<RideRequestEntity>? requests,
    String? error,
  }) {
    return RiderRequestState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      requests: requests ?? this.requests,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, requests, error];
}

// --- Bloc ---
class RiderRequestBloc extends Bloc<RiderRequestEvent, RiderRequestState> {
  final RideRemoteDataSource dataSource;

  RiderRequestBloc(this.dataSource) : super(const RiderRequestState()) {
    
    on<LoadRiderRequestsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, isSuccess: false, error: null));
      try {
        final data = await dataSource.getIncomingRequests();
        emit(state.copyWith(isLoading: false, requests: data));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<AcceptRequestEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, isSuccess: false));
      try {
        await dataSource.respondToRequest(event.id, 'accepted');
        // ✅ Set isSuccess to true to trigger SnackBar in UI
        emit(state.copyWith(isLoading: false, isSuccess: true));
        add(LoadRiderRequestsEvent()); // Reload list
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: "Failed to accept request"));
      }
    });

    on<RejectRequestEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, isSuccess: false));
      try {
        await dataSource.respondToRequest(event.id, 'rejected');
        // ✅ Set isSuccess to true to trigger SnackBar in UI
        emit(state.copyWith(isLoading: false, isSuccess: true));
        add(LoadRiderRequestsEvent()); // Reload list
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: "Failed to reject request"));
      }
    });
  }
}