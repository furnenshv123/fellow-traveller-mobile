import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/passenger_profile_model.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/widgets/passenger_rating_dialog.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/edit_ride_dialog.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverRideRequestsScreen extends StatefulWidget {
  const DriverRideRequestsScreen({required this.ride, super.key});

  final RideModel ride;

  @override
  State<DriverRideRequestsScreen> createState() =>
      _DriverRideRequestsScreenState();
}

class _DriverRideRequestsScreenState extends State<DriverRideRequestsScreen> {
  late Future<List<DriverPassengerRequestModel>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _requestsFuture =
        AppDependencies.instance.ridesRepository.getRideRequests(widget.ride.id);
  }

  String _formatDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  Future<void> _openEditRide() async {
    await showEditRideDialog(context: context, ride: widget.ride);
  }

  void _openPassengerProfile(DriverPassengerRequestModel request) {
    final profile = PassengerProfileModel(
      id: request.passengerProfileId,
      userId: request.passengerProfileId,
      fullName: request.passengerName,
      phone: request.passengerPhone,
      avgRating: request.passengerRating ?? 0,
      photoUrl: request.passengerPhoto,
    );
    context.push(
      AppRoutesEnum.userPassengerProfile.pathWithProfileId(request.passengerProfileId),
      extra: profile,
    );
  }

  Future<void> _openPassengerRating(DriverPassengerRequestModel request) async {
    await showPassengerRatingDialog(
      context: context,
      passengerProfileId: request.passengerProfileId,
      passengerName: request.passengerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Запросы на поездку'),
        actions: <Widget>[
          IconButton(
            onPressed: _openEditRide,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RideHeader(
            ride: widget.ride,
            formatDate: _formatDate,
          ),
          Expanded(
            child: FutureBuilder<List<DriverPassengerRequestModel>>(
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

                final requests =
                    snapshot.data ?? <DriverPassengerRequestModel>[];

                if (requests.isEmpty) {
                  return const Center(
                    child: Text(
                      'Пока нет запросов',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_load);
                    await _requestsFuture;
                  },
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final request = requests[index];
                      return _PassengerRequestCard(
                        request: request,
                        onProfileTap: () => _openPassengerProfile(request),
                        onRateTap: request.status == RideRequestStatus.accepted
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
            '${ride.availablePlaces} мест · ${ride.price.toInt()} ₸',
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
    this.onRateTap,
  });

  final DriverPassengerRequestModel request;
  final VoidCallback onProfileTap;
  final VoidCallback? onRateTap;

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == RideRequestStatus.pending;

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
          if (isPending) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
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
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Принять'),
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
