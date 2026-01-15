class RiderKycState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  RiderKycState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory RiderKycState.initial() {
    return RiderKycState(isLoading: false, isSuccess: false, errorMessage: null);
  }

  RiderKycState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return RiderKycState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}