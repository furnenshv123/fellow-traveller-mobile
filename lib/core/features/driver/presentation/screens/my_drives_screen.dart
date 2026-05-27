import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/ride_card.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class DriverMyRidesScreen extends StatefulWidget {
  const DriverMyRidesScreen({super.key});

  @override
  State<DriverMyRidesScreen> createState() => _DriverMyRidesScreenState();
}

class _DriverMyRidesScreenState extends State<DriverMyRidesScreen> {
  late Future<List<RideModel>> _ridesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _ridesFuture = AppDependencies.instance.ridesRepository.getMyRides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        title: const Text(
          'Мои поездки',
          style: TextStyle(
            color: AppColors.textVeryLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<List<RideModel>>(
        future: _ridesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<RideModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Не удалось загрузить поездки',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final rides = snapshot.data ?? <RideModel>[];

          if (rides.isEmpty) {
            return const Center(
              child: Text(
                'Создайте поездку на главной вкладке',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(_load);
              await _ridesFuture;
            },
            color: AppColors.accentBlue,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final ride = rides[index];
                return RideCard(
                  ride: ride,
                  subtitle: '${ride.date} · ${ride.time} · ${ride.availablePlaces} мест',
                  trailing: ride.pendingRequestsCount > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${ride.price.toInt()} ₸',
                              style: const TextStyle(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ride.pendingRequestsCount} запросов',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFE67E22),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : null,
                  onTap: () => _showRequests(context, ride),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRequests(BuildContext context, RideModel ride) async {
    final repository = AppDependencies.instance.ridesRepository;
    final requests = await repository.getRideRequests(ride.id);

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Запросы · ${ride.routeLabel}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: requests.isEmpty
                        ? const Center(
                            child: Text(
                              'Пока нет запросов',
                              style: TextStyle(color: AppColors.textGray),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: requests.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final request = requests[index];
                              return _PassengerRequestTile(request: request);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PassengerRequestTile extends StatelessWidget {
  const _PassengerRequestTile({required this.request});

  final DriverPassengerRequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            request.passengerName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.seatsRequested} мест · ${request.status.labelRu}',
            style: const TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          if (request.passengerRating != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Рейтинг ${request.passengerRating}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0x44C62828)),
                  ),
                  child: const Text('Отклонить'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                  ),
                  child: const Text('Принять'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
