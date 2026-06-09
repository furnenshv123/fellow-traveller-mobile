import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/data/rides_tab_refresh_notifier.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/ride_card.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverMyRidesScreen extends StatefulWidget {
  const DriverMyRidesScreen({super.key});

  @override
  State<DriverMyRidesScreen> createState() => _DriverMyRidesScreenState();
}

class _DriverMyRidesScreenState extends State<DriverMyRidesScreen> {
  late Future<List<RideModel>> _ridesFuture;
  late final RidesTabRefreshNotifier _ridesRefresh;
  int _ridesLoadId = 0;

  @override
  void initState() {
    super.initState();
    _ridesRefresh = AppDependencies.instance.ridesTabRefreshNotifier;
    _ridesRefresh.addListener(_onRidesRefreshRequested);
    _load();
  }

  @override
  void dispose() {
    _ridesRefresh.removeListener(_onRidesRefreshRequested);
    super.dispose();
  }

  void _onRidesRefreshRequested() {
    if (!mounted) {
      return;
    }
    setState(_load);
  }

  Future<void> _reload() async {
    setState(_load);
    await _ridesFuture;
  }

  void _load() {
    _ridesLoadId++;
    _ridesFuture = AppDependencies.instance.ridesRepository.getMyRides();
  }

  Future<void> _openRequests(RideModel ride) async {
    await context.push(AppRoutesEnum.driverRideRequests.path, extra: ride);
    if (!mounted) {
      return;
    }
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppScreenBody(
        withBottomNav: true,
        child: FutureBuilder<List<RideModel>>(
        key: ValueKey<int>(_ridesLoadId),
        future: _ridesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<RideModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
            onRefresh: _reload,
            color: AppColors.primary,
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
                              PriceFormatter.format(ride.price),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ride.pendingRequestsCount} запросов',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.accentAmber,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : null,
                  onTap: () => _openRequests(ride),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }
}
