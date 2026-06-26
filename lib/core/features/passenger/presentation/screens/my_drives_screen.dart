import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/data/rides_tab_refresh_notifier.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/rating_submission.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/widgets/pending_rating_banner.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';
import 'package:fellow_traveller_mobile/core/utils/app_bottom_sheet.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/price_formatter.dart';
import 'package:fellow_traveller_mobile/core/utils/user_profile_navigation.dart';
import 'package:fellow_traveller_mobile/core/utils/maps_route_launcher.dart';
import 'package:fellow_traveller_mobile/core/utils/phone_launcher.dart';
import 'package:flutter/material.dart';

class PassengerMyRidesScreen extends StatefulWidget {
  const PassengerMyRidesScreen({super.key});

  @override
  State<PassengerMyRidesScreen> createState() => _PassengerMyRidesScreenState();
}

class _PassengerMyRidesScreenState extends State<PassengerMyRidesScreen> {
  late Future<List<PassengerRideRequestModel>> _requestsFuture;
  late final RidesTabRefreshNotifier _ridesRefresh;
  int _requestsLoadId = 0;
  Set<int> _ratedDriverIds = <int>{};
  int? _cancellingId;

  @override
  void initState() {
    super.initState();
    _ridesRefresh = AppDependencies.instance.ridesTabRefreshNotifier;
    _ridesRefresh.addListener(_onRidesRefreshRequested);
    _load();
    _loadRatedDrivers();
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
    _refresh();
  }

  void _load() {
    _requestsLoadId++;
    _requestsFuture =
        AppDependencies.instance.ridesRepository.getMyPassengerRequests();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _requestsFuture;
    await _loadRatedDrivers();
  }

  Future<void> _loadRatedDrivers() async {
    final ids = await loadRatedDriverIds();
    if (mounted) {
      setState(() => _ratedDriverIds = ids);
    }
  }

  String _formatDisplayDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  Future<void> _openDriverProfile(PassengerRideRequestModel request) async {
    final profileId = await AppDependencies.instance.ridesRepository
        .resolveDriverProfileId(request);
    if (!mounted || profileId == null) {
      return;
    }
    UserProfileNavigation.openDriverProfile(context, profileId: profileId);
  }

  Future<void> _openRating(PassengerRideRequestModel request) async {
    final driverId = await AppDependencies.instance.ridesRepository
        .resolveDriverProfileId(request);
    final driverName = request.driverName;
    if (driverId == null || driverName == null) {
      return;
    }

    final rated = await RatingSubmission.rateDriver(
      context: context,
      driverProfileId: driverId,
      driverName: driverName,
    );

    if (rated && mounted) {
      setState(() => _ratedDriverIds.add(driverId));
    }
  }

  Future<void> _cancelRequest(PassengerRideRequestModel request) async {
    if (_cancellingId != null) {
      return;
    }

    setState(() => _cancellingId = request.id);

    try {
      await AppDependencies.instance.ridesRepository.cancelRideRequest(
        request.id,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Заявка отменена')));
      await _refresh();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Не удалось отменить заявку')));
    } finally {
      if (mounted) {
        setState(() => _cancellingId = null);
      }
    }
  }

  PassengerRideRequestModel? _firstPendingRating(
    List<PassengerRideRequestModel> requests,
  ) {
    for (final request in requests) {
      final driverId = request.driverProfileId;
      if (driverId == null || request.driverName == null) {
        continue;
      }
      if (request.canRateDriver && !_ratedDriverIds.contains(driverId)) {
        return request;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppScreenBody(
        withBottomNav: true,
        child: FutureBuilder<List<PassengerRideRequestModel>>(
        key: ValueKey<int>(_requestsLoadId),
        future: _requestsFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<PassengerRideRequestModel>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Не удалось загрузить поездки',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9)),
              ),
            );
          }

          final requests =
              snapshot.data ?? <PassengerRideRequestModel>[];
          final pendingRating = _firstPendingRating(requests);

          if (requests.isEmpty) {
            return Center(
              child: Text(
                'У вас пока нет заявок на поездки',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length + (pendingRating != null ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                if (pendingRating != null && index == 0) {
                  return PendingRatingBanner(
                    title: 'Поездка завершена',
                    subtitle: 'Оцените водителя ${pendingRating.driverName}',
                    onRate: () => _openRating(pendingRating),
                  );
                }

                final requestIndex = pendingRating != null ? index - 1 : index;
                final request = requests[requestIndex];
                final driverId = request.driverProfileId;
                final canRate = request.canRateDriver &&
                    driverId != null &&
                    !_ratedDriverIds.contains(driverId);
                return _RequestCard(
                  request: request,
                  formatDate: _formatDisplayDate,
                  canRate: canRate,
                  isCancelling: _cancellingId == request.id,
                  onRate: canRate ? () => _openRating(request) : null,
                  onCancel: request.status == RideRequestStatus.pending
                      ? () => _cancelRequest(request)
                      : null,
                  onDriverTap: driverId != null
                      ? () => _openDriverProfile(request)
                      : null,
                  onTap: () => _showDetails(context, request, canRate: canRate),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final launched = await PhoneLauncher.call(phone);
    if (!mounted || launched) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Не удалось открыть приложение для звонка')),
      );
  }

  Future<void> _openRouteInMaps(PassengerRideRequestModel request) async {
    final opened = await MapsRouteLauncher.openRoute(
      from: request.fromPoint.name,
      to: request.toPoint.name,
    );
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Не удалось открыть карты')),
      );
  }

  void _showDetails(
    BuildContext context,
    PassengerRideRequestModel request, {
    required bool canRate,
  }) {
    showAppBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
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
                request.routeLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Статус', request.status.labelRu),
              _detailRow('Мест', '${request.seatsRequested}'),
              _detailRow('Дата', _formatDisplayDate(request.date)),
              _detailRow('Время', request.time),
              if (request.driverName != null)
                InkWell(
                  onTap: request.driverProfileId != null
                      ? () {
                          Navigator.pop(context);
                          _openDriverProfile(request);
                        }
                      : null,
                  child: _detailRow('Водитель', request.driverName!),
                ),
              if (request.driverPhone != null) ...<Widget>[
                _detailRow('Телефон', request.driverPhone!),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _callPhone(request.driverPhone!),
                  icon: const Icon(Icons.phone_rounded),
                  label: const Text('Позвонить водителю'),
                ),
              ],
              if (request.driverCarModel != null)
                _detailRow('Авто', request.driverCarModel!),
              _detailRow('Цена', PriceFormatter.format(request.price)),
              if (canRate) ...<Widget>[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _openRating(request);
                  },
                  icon: const Icon(Icons.star_rounded),
                  label: const Text('Оценить водителя'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentAmber,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _openRouteInMaps(request),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Маршрут на карте'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.formatDate,
    required this.onTap,
    this.canRate = false,
    this.onRate,
    this.onCancel,
    this.onDriverTap,
    this.isCancelling = false,
  });

  final PassengerRideRequestModel request;
  final String Function(String iso) formatDate;
  final VoidCallback onTap;
  final bool canRate;
  final VoidCallback? onRate;
  final VoidCallback? onCancel;
  final VoidCallback? onDriverTap;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = request.isUpcoming;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      request.routeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBody,
                      ),
                    ),
                  ),
                  Text(
                    PriceFormatter.format(request.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${formatDate(request.date)} · ${request.time}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              if (request.driverName != null) ...<Widget>[
                const SizedBox(height: 8),
                InkWell(
                  onTap: onDriverTap,
                  child: Row(
                    children: <Widget>[
                      Text(
                        request.driverName!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (onDriverTap != null) ...<Widget>[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? AppColors.primaryLight.withValues(alpha: 0.5)
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.status.labelRu,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isUpcoming ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ),
                  if (onCancel != null) ...<Widget>[
                    const Spacer(),
                    TextButton(
                      onPressed: isCancelling ? null : onCancel,
                      child: isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Отменить',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                    ),
                  ],
                  if (canRate) ...<Widget>[
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onRate,
                      icon: const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.accentAmber,
                      ),
                      label: const Text(
                        'Оценить',
                        style: TextStyle(
                          color: AppColors.accentAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
