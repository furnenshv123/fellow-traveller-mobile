import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/widgets/driver_rating_dialog.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/profile_ui_mapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PassengerMyRidesScreen extends StatefulWidget {
  const PassengerMyRidesScreen({super.key});

  @override
  State<PassengerMyRidesScreen> createState() => _PassengerMyRidesScreenState();
}

class _PassengerMyRidesScreenState extends State<PassengerMyRidesScreen> {
  late Future<List<PassengerRideRequestModel>> _requestsFuture;
  final Set<int> _ratedDriverIds = <int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _requestsFuture =
        AppDependencies.instance.ridesRepository.getMyPassengerRequests();
  }

  String _formatDisplayDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  void _openDriverProfile(PassengerRideRequestModel request) {
    final profileId = request.driverProfileId;
    if (profileId == null) {
      return;
    }
    context.push(
      AppRoutesEnum.userDriverProfile.pathWithProfileId(profileId),
      extra: ProfileUiMapper.fromPassengerRequest(request),
    );
  }

  Future<void> _openRating(PassengerRideRequestModel request) async {
    final driverId = request.driverProfileId;
    final driverName = request.driverName;
    if (driverId == null || driverName == null) {
      return;
    }

    final result = await showDriverRatingDialog(
      context: context,
      driverProfileId: driverId,
      driverName: driverName,
    );

    if (result != null && mounted) {
      setState(() => _ratedDriverIds.add(driverId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<PassengerRideRequestModel>>(
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

          if (requests.isEmpty) {
            return Center(
              child: Text(
                'У вас пока нет заявок на поездки',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9)),
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
                final canRate = request.canRateDriver &&
                    request.driverProfileId != null &&
                    !_ratedDriverIds.contains(request.driverProfileId);
                return _RequestCard(
                  request: request,
                  formatDate: _formatDisplayDate,
                  canRate: canRate,
                  onRate: canRate ? () => _openRating(request) : null,
                  onDriverTap: request.driverProfileId != null
                      ? () => _openDriverProfile(request)
                      : null,
                  onTap: () => _showDetails(context, request, canRate: canRate),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetails(
    BuildContext context,
    PassengerRideRequestModel request, {
    required bool canRate,
  }) {
    showModalBottomSheet<void>(
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
              if (request.driverPhone != null)
                _detailRow('Телефон', request.driverPhone!),
              if (request.driverCarModel != null)
                _detailRow('Авто', request.driverCarModel!),
              _detailRow('Цена', '${request.price.toInt()} ₸'),
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
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Закрыть'),
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
    this.onDriverTap,
  });

  final PassengerRideRequestModel request;
  final String Function(String iso) formatDate;
  final VoidCallback onTap;
  final bool canRate;
  final VoidCallback? onRate;
  final VoidCallback? onDriverTap;

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
                    '${request.price.toInt()} ₸',
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
