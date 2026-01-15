import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

abstract class HomeEvent {}
class LoadCurrentLocationEvent extends HomeEvent {}

class HomeState {
  final LatLng? currentLocation;
  final bool isLoading;
  final String? error;

  HomeState({this.currentLocation, this.isLoading = false, this.error});
}

class HomeViewModel extends Bloc<HomeEvent, HomeState> {
  HomeViewModel() : super(HomeState()) {
    on<LoadCurrentLocationEvent>(_getCurrentLocation);
  }

  Future<void> _getCurrentLocation(LoadCurrentLocationEvent event, Emitter<HomeState> emit) async {
    emit(HomeState(isLoading: true));

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(HomeState(error: "Location services are disabled."));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(HomeState(error: "Location permissions are denied"));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(HomeState(error: "Location permissions are permanently denied."));
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      
      emit(HomeState(
        currentLocation: LatLng(position.latitude, position.longitude),
        isLoading: false,
      ));
    } catch (e) {
      emit(HomeState(error: e.toString()));
    }
  }
}