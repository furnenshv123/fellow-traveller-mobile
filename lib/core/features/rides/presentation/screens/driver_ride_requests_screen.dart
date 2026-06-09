import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/data/rides_tab_refresh_notifier.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/rating_submission.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/widgets/pending_rating_banner.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/edit_ride_dialog.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fellow_traveller_mobile/core/utils/user_profile_navigation.dart';

class DriverRideRequestsScreen extends StatefulWidget {
  const DriverRideRequestsScreen({required this.ride, super.key});

  final RideModel ride;

  @override
  State<DriverRideRequestsScreen> createState() =>
      _DriverRideRequestsScreenState();
}

class _DriverRideRequestsScreenState extends State<DriverRideRequestsScreen> {
  late RideModel _ride;
  late Future<List<DriverPassengerRequestModel>> _requestsFuture;
  late final RidesTabRefreshNotifier _ridesRefresh;
  int _requestsLoadId = 0;
  final Set<int> _processingIds = <int>{};
  final Set<int> _ratedPassengerIds = <int>{};
  bool _isUpdatingRide = false;
  bool _isDeletingRide = false;

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
    _ridesRefresh = AppDependencies.instance.ridesTabRefreshNotifier;
    _ridesRefresh.addListener(_onRidesRefreshRequested);
    _startLoad();
  }

  @override
  void dispose() {
    _ridesRefresh.removeListener(_onRidesRefreshRequested);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DriverRideRequestsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ride.id != widget.ride.id) {
      _ride = widget.ride;
      _load();
    }
  }

  void _onRidesRefreshRequested() {
    if (!mounted) {
      return;
    }
    _load();
  }

  void _startLoad() {
    _requestsLoadId++;
    _requestsFuture =
        AppDependencies.instance.ridesRepository.getRideRequests(_ride.id);
  }

  void _load() {
    setState(_startLoad);
  }

  Future<void> _refresh() async {
    _load();
    await _requestsFuture;
  }

  Future<void> _accept(DriverPassengerRequestModel request) async {
    await _respond(request, accepted: true);
  }

  Future<void> _reject(DriverPassengerRequestModel request) async {
    await _respond(request, accepted: false);
  }

  Future<void> _respond(
    DriverPassengerRequestModel request, {
    required bool accepted,
  }) async {
    if (_processingIds.contains(request.id)) {
      return;
    }

    setState(() => _processingIds.add(request.id));

    try {
      final repo = AppDependencies.instance.ridesRepository;
      if (accepted) {
        await repo.acceptRideRequest(request.id);
      } else {
        await repo.rejectRideRequest(request.id);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              accepted ? 'Заявка принята' : 'Заявка отклонена',
            ),
          ),
        );
      await _refresh();
      AppDependencies.instance.ridesTabRefreshNotifier.requestRefresh();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось обновить заявку')),
        );
    } finally {
      if (mounted) {
        setState(() => _processingIds.remove(request.id));
      }
    }
  }

  bool _canRatePassenger(DriverPassengerRequestModel request) {
    return request.status == RideRequestStatus.accepted &&
        isRideFinished(_ride.date) &&
        !_ratedPassengerIds.contains(request.passengerProfileId);
  }

  DriverPassengerRequestModel? _firstPendingRating(
    List<DriverPassengerRequestModel> requests,
  ) {
    for (final request in requests) {
      if (_canRatePassenger(request)) {
        return request;
      }
    }
    return null;
  }

  Future<void> _openPassengerRating(DriverPassengerRequestModel request) async {
    final rated = await RatingSubmission.ratePassenger(
      context: context,
      passengerProfileId: request.passengerProfileId,
      passengerName: request.passengerName,
    );
    if (rated && mounted) {
      setState(() => _ratedPassengerIds.add(request.passengerProfileId));
    }
  }

  String _formatDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  Future<void> _openEditRide() async {
    if (_isUpdatingRide || _isDeletingRide) {
      return;
    }

    final params = await showEditRideDialog(context: context, ride: _ride);
    if (params == null || !mounted) {
      return;
    }

    setState(() => _isUpdatingRide = true);

    try {
      final updated = await AppDependencies.instance.ridesRepository.updateRide(
        _ride.id,
        params,
      );
      if (!mounted) {
        return;
      }
      setState(() => _ride = updated);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Поездка обновлена')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось обновить поездку')),
        );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingRide = false);
      }
    }
  }

  Future<void> _confirmDeleteRide() async {
    if (_isUpdatingRide || _isDeletingRide) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Удалить поездку?'),
          content: Text(
            'Маршрут ${_ride.routeLabel} будет удалён без возможности восстановления.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isDeletingRide = true);

    try {
      await AppDependencies.instance.ridesRepository.deleteRide(_ride.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Поездка удалена')));
      context.pop();
      AppDependencies.instance.ridesTabRefreshNotifier.requestRefresh();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось удалить поездку')),
        );
    } finally {
      if (mounted) {
        setState(() => _isDeletingRide = false);
      }
    }
  }

  void _openPassengerProfile(DriverPassengerRequestModel request) {
    UserProfileNavigation.openPassengerProfile(
      context,
      profileId: request.passengerProfileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Запросы на поездку'),
        actions: <Widget>[
          if (_isUpdatingRide || _isDeletingRide)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...<Widget>[
            IconButton(
              onPressed: _openEditRide,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: _confirmDeleteRide,
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
            ),
          ],
        ],
      ),
      body: AppScreenBody(
        includeTopInset: false,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RideHeader(
            ride: _ride,
            formatDate: _formatDate,
          ),
          Expanded(
            child: FutureBuilder<List<DriverPassengerRequestModel>>(
              key: ValueKey<int>(_requestsLoadId),
              future: _requestsFuture,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<DriverPassengerRequestModel>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Не удалось загрузить запросы',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final requests =
                    snapshot.data ?? <DriverPassengerRequestModel>[];
                final pendingRating = _firstPendingRating(requests);

                if (requests.isEmpty) {
                  return const Center(
                    child: Text(
                      'Пока нет запросов',
                      style: TextStyle(color: AppColors.textSecondary),
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
                          subtitle:
                              'Оцените пассажира ${pendingRating.passengerName}',
                          onRate: () => _openPassengerRating(pendingRating),
                        );
                      }

                      final requestIndex =
                          pendingRating != null ? index - 1 : index;
                      final request = requests[requestIndex];
                      final isProcessing = _processingIds.contains(request.id);
                      return _PassengerRequestCard(
                        request: request,
                        isProcessing: isProcessing,
                        onProfileTap: () => _openPassengerProfile(request),
                        onAccept: request.status == RideRequestStatus.pending
                            ? () => _accept(request)
                            : null,
                        onReject: request.status == RideRequestStatus.pending
                            ? () => _reject(request)
                            : null,
                        onRateTap: _canRatePassenger(request)
                            ? () => _openPassengerRating(request)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _RideHeader extends StatelessWidget {
  const _RideHeader({required this.ride, required this.formatDate});

  final RideModel ride;
  final String Function(String iso) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ride.routeLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatDate(ride.date)} · ${ride.time}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${ride.availablePlaces} мест · ${PriceFormatter.format(ride.price)}',
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

class _PassengerRequestCard extends StatelessWidget {
  const _PassengerRequestCard({
    required this.request,
    required this.onProfileTap,
    this.onAccept,
    this.onReject,
    this.onRateTap,
    this.isProcessing = false,
  });

  final DriverPassengerRequestModel request;
  final VoidCallback onProfileTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onRateTap;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(AppColors.radiusSm),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: request.passengerPhoto != null
                      ? NetworkImage(request.passengerPhoto!)
                      : null,
                  child: request.passengerPhoto == null
                      ? Text(
                          request.passengerName.isNotEmpty
                              ? request.passengerName[0]
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        request.passengerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      if (request.passengerRating != null)
                        Text(
                          'Рейтинг ${request.passengerRating}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${request.seatsRequested} мест · ${request.status.labelRu}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          if (request.passengerPhone != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              request.passengerPhone!,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          if (onAccept != null && onReject != null) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: const Text('Отклонить'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isProcessing ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Принять'),
                  ),
                ),
              ],
            ),
          ],
          if (onRateTap != null) ...<Widget>[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRateTap,
                icon: const Icon(Icons.star_outline_rounded, size: 18),
                label: const Text('Оценить пассажира'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
