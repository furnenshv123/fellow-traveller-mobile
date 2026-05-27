import 'package:bloc/bloc.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/rides_repository.dart';
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

    if (event.from == null ||
        event.to == null ||
        event.dateIso == null ||
        event.time == null ||
        event.time!.isEmpty) {
      emit(current.copyWith(errorMessage: 'Заполните маршрут, дату и время'));
      return;
    }

    if (event.from!.id == event.to!.id) {
      emit(current.copyWith(errorMessage: 'Выберите разные города'));
      return;
    }

    if (event.seats <= 0 || event.price <= 0) {
      emit(current.copyWith(errorMessage: 'Укажите количество мест и цену'));
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
