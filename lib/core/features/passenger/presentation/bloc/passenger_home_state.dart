part of 'passenger_home_bloc.dart';

@immutable
sealed class PassengerHomeState {
  const PassengerHomeState();
}

class PassengerHomeInitial extends PassengerHomeState {
  const PassengerHomeInitial();
}

class PassengerHomeReady extends PassengerHomeState {
  const PassengerHomeReady({
    required this.results,
    required this.hasSearched,
    this.isSearching = false,
    this.errorMessage,
  });

  final List<RideModel> results;
  final bool hasSearched;
  final bool isSearching;
  final String? errorMessage;

  PassengerHomeReady copyWith({
    List<RideModel>? results,
    bool? hasSearched,
    bool? isSearching,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PassengerHomeReady(
      results: results ?? this.results,
      hasSearched: hasSearched ?? this.hasSearched,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
