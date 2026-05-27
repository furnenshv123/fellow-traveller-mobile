import 'package:bloc/bloc.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/rides_repository.dart';
import 'package:meta/meta.dart';

part 'passenger_home_event.dart';
part 'passenger_home_state.dart';

class PassengerHomeBloc extends Bloc<PassengerHomeEvent, PassengerHomeState> {
  PassengerHomeBloc(this._ridesRepository) : super(const PassengerHomeInitial()) {
    on<PassengerHomeStarted>(_onStarted);
    on<PassengerHomeSearchSubmitted>(_onSearchSubmitted);
  }

  final RidesRepository _ridesRepository;

  void _onStarted(PassengerHomeStarted event, Emitter<PassengerHomeState> emit) {
    emit(
      const PassengerHomeReady(
        results: <RideModel>[],
        hasSearched: false,
      ),
    );
  }

  Future<void> _onSearchSubmitted(
    PassengerHomeSearchSubmitted event,
    Emitter<PassengerHomeState> emit,
  ) async {
    final current = state;
    if (current is! PassengerHomeReady) {
      return;
    }

    final from = event.from;
    final to = event.to;
    final dateIso = event.dateIso;

    if (from == null || to == null || dateIso == null || dateIso.isEmpty) {
      emit(current.copyWith(errorMessage: 'Укажите маршрут и дату'));
      return;
    }

    if (from.id == to.id) {
      emit(
        current.copyWith(
          errorMessage: 'Города отправления и назначения должны отличаться',
        ),
      );
      return;
    }

    emit(current.copyWith(isSearching: true, clearError: true));

    try {
      final results = await _ridesRepository.searchRides(
        RideSearchParams(
          fromPointId: from.id,
          toPointId: to.id,
          date: dateIso,
        ),
      );
      emit(
        current.copyWith(
          results: results,
          hasSearched: true,
          isSearching: false,
        ),
      );
    } catch (_) {
      emit(
        current.copyWith(
          isSearching: false,
          errorMessage: 'Ошибка поиска. Попробуйте снова.',
        ),
      );
    }
  }
}
