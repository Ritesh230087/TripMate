import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/features/ride/domain/entity/rider_kyc_entity.dart';
import 'package:tripmate/features/ride/domain/use_case/apply_rider_usecase.dart';
import 'rider_kyc_event.dart';
import 'rider_kyc_state.dart';

class RiderKycViewModel extends Bloc<RiderKycEvent, RiderKycState> {
  final ApplyRiderUseCase applyRiderUseCase;

  RiderKycViewModel(this.applyRiderUseCase) : super(RiderKycState.initial()) {
    on<SubmitKycEvent>(_onSubmitKyc);
  }

Future<void> _onSubmitKyc(SubmitKycEvent event, Emitter<RiderKycState> emit) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));

    final kycEntity = RiderKycEntity(
      citizenshipFront: event.citizenshipFront,
      citizenshipBack: event.citizenshipBack,
      licenseNumber: event.licenseNumber,
      licenseExpiry: event.licenseExpiryDate,
      licenseIssue: event.licenseIssueDate,
      licenseImage: event.licenseImage,
      selfieWithLicense: event.selfieWithLicense,
      vehicleModel: event.vehicleModel,
      vehicleYear: event.vehicleProductionYear,
      vehiclePlate: event.vehiclePlateNumber,
      vehiclePhoto: event.vehiclePhoto,
      billbookPage2: event.billbookPage2,
      billbookPage3: event.billbookPage3,
    );

    final result = await applyRiderUseCase(kycEntity);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (success) => emit(state.copyWith(isLoading: false, isSuccess: true)), // Just update state
    );
}
}