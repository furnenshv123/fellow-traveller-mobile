part of 'driver_home_bloc.dart';

@immutable
sealed class DriverHomeState {
  const DriverHomeState();
}

class DriverHomeInitial extends DriverHomeState {
  const DriverHomeInitial();
}

class DriverHomeReady extends DriverHomeState {
  const DriverHomeReady({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.lastCreatedRide,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final RideModel? lastCreatedRide;

  DriverHomeReady copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    RideModel? lastCreatedRide,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DriverHomeReady(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      lastCreatedRide: lastCreatedRide ?? this.lastCreatedRide,
    );
  }
}
