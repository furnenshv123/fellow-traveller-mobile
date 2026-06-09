import 'package:bloc/bloc.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/rides_repository.dart';
import 'package:fellow_traveller_mobile/core/utils/validators/ride_validators.dart';
import 'package:meta/meta.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc(this._ridesRepository) : super(const DriverHomeInitial()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverHomeRideSubmitted>(_onRideSubmitted);
  }

  final RidesRepository _ridesRepository;

  void _onStarted(DriverHomeStarted event, Emitter<DriverHomeState> emit) {
    emit(const DriverHomeReady());
  }

  Future<void> _onRideSubmitted(
    DriverHomeRideSubmitted event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady) {
      return;
    }

    final routeError = RideValidators.routePoints(
      fromId: event.from?.id,
      toId: event.to?.id,
    );
    if (routeError != null) {
      emit(current.copyWith(errorMessage: routeError));
      return;
    }

    final dateError = RideValidators.dateIso(event.dateIso);
    final timeError = RideValidators.time(event.time);
    final seatsError = RideValidators.seats(event.seats.toString());
    final priceError = RideValidators.price(event.price.toString());

    if (dateError != null ||
        timeError != null ||
        seatsError != null ||
        priceError != null) {
      emit(
        current.copyWith(
          errorMessage: dateError ??
              timeError ??
              seatsError ??
              priceError,
        ),
      );
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearError: true, clearSuccess: true));

    try {
      final ride = await _ridesRepository.createRide(
        RideCreateParams(
          fromPointId: event.from!.id,
          toPointId: event.to!.id,
          date: event.dateIso!,
          time: event.time!,
          availablePlaces: event.seats,
          price: event.price,
        ),
      );
      emit(
        current.copyWith(
          isSubmitting: false,
          lastCreatedRide: ride,
          successMessage: 'Поездка создана',
        ),
      );
      AppDependencies.instance.ridesTabRefreshNotifier.requestRefresh();
    } catch (_) {
      emit(
        current.copyWith(
          isSubmitting: false,
          errorMessage: 'Не удалось создать поездку',
        ),
      );
    }
  }
}
