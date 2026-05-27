import 'package:fellow_traveller_mobile/core/features/passenger/presentation/bloc/passenger_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/point_search_field.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/ride_card.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  PointModel? _from;
  PointModel? _to;
  String? _dateIso;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dateIso != null
        ? DateTime.tryParse(_dateIso!) ?? now
        : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ru', 'RU'),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _dateIso =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  String _formatDisplayDate(String? iso) {
    if (iso == null || iso.isEmpty) {
      return 'Выберите дату';
    }
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  void _submitSearch() {
    context.read<PassengerHomeBloc>().add(
          PassengerHomeSearchSubmitted(
            from: _from,
            to: _to,
            dateIso: _dateIso,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        title: const Text(
          'Поиск поездок',
          style: TextStyle(
            color: AppColors.textVeryLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocConsumer<PassengerHomeBloc, PassengerHomeState>(
        listener: (BuildContext context, PassengerHomeState state) {
          if (state is PassengerHomeReady && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (BuildContext context, PassengerHomeState state) {
          final ready = state is PassengerHomeReady
              ? state
              : const PassengerHomeReady(results: <RideModel>[], hasSearched: false);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PassengerHomeBloc>().add(const PassengerHomeStarted());
            },
            color: AppColors.accentBlue,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: <Widget>[
                _buildSearchCard(ready),
                const SizedBox(height: 24),
                Text(
                  ready.hasSearched ? 'Результаты' : 'Доступные направления',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                if (ready.isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accentBlue),
                    ),
                  )
                else if (ready.hasSearched && ready.results.isEmpty)
                  _emptyState('По вашему маршруту и дате поездок не найдено')
                else
                  ...ready.results.map(
                    (RideModel ride) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RideCard(
                        ride: ride,
                        onTap: () => _showRideDetails(context, ride),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard(PassengerHomeReady state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PointSearchField(
            key: ValueKey<String>('from_${_from?.id}'),
            label: 'Откуда',
            hint: 'откуда',
            value: _from,
            onChanged: (PointModel? value) => setState(() => _from = value),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => setState(() {
                final temp = _from;
                _from = _to;
                _to = temp;
              }),
              icon: const Icon(Icons.swap_vert_rounded, color: AppColors.accentBlue),
            ),
          ),
          PointSearchField(
            key: ValueKey<String>('to_${_to?.id}'),
            label: 'Куда',
            hint: 'куда',
            value: _to,
            icon: Icons.flag_outlined,
            onChanged: (PointModel? value) => setState(() => _to = value),
          ),
          const SizedBox(height: 16),
          const Text(
            'Дата',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.inputDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.calendar_month_outlined, color: AppColors.accentBlue),
                  const SizedBox(width: 10),
                  Text(
                    _formatDisplayDate(_dateIso),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.isSearching ? null : _submitSearch,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Найти поездки',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textGray, fontSize: 15),
      ),
    );
  }

  void _showRideDetails(BuildContext context, RideModel ride) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                ride.routeLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              if (ride.driverName != null)
                Text(
                  'Водитель: ${ride.driverName}',
                  style: const TextStyle(color: AppColors.textGray),
                ),
              if (ride.driverRating != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Рейтинг: ${ride.driverRating}',
                  style: const TextStyle(color: AppColors.textGray),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${ride.date} · ${ride.time} · ${ride.availablePlaces} мест · ${ride.price.toInt()} ₸',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: AppColors.accentBlue),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        );
      },
    );
  }
}
