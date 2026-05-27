import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class PassengerMyRidesScreen extends StatefulWidget {
  const PassengerMyRidesScreen({super.key});

  @override
  State<PassengerMyRidesScreen> createState() => _PassengerMyRidesScreenState();
}

class _PassengerMyRidesScreenState extends State<PassengerMyRidesScreen> {
  late Future<List<PassengerRideRequestModel>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _requestsFuture = AppDependencies.instance.ridesRepository.getMyPassengerRequests();
  }

  String _formatDisplayDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
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
      body: FutureBuilder<List<PassengerRideRequestModel>>(
        future: _requestsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<PassengerRideRequestModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
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

          final requests = snapshot.data ?? <PassengerRideRequestModel>[];

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
            color: AppColors.accentBlue,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final request = requests[index];
                return _RequestCard(
                  request: request,
                  formatDate: _formatDisplayDate,
                  onTap: () => _showDetails(context, request),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, PassengerRideRequestModel request) {
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
                request.routeLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('Статус', request.status.labelRu),
              _detailRow('Дата', _formatDisplayDate(request.date)),
              _detailRow('Время', request.time),
              if (request.driverName != null)
                _detailRow('Водитель', request.driverName!),
              if (request.driverPhone != null)
                _detailRow('Телефон', request.driverPhone!),
              _detailRow('Цена', '${request.price.toInt()} ₸'),
              const SizedBox(height: 16),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textGray)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textLight,
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
  });

  final PassengerRideRequestModel request;
  final String Function(String iso) formatDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = request.isUpcoming;

    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
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
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  Text(
                    '${request.price.toInt()} ₸',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${formatDate(request.date)} · ${request.time}',
                style: const TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
              if (request.driverName != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  request.driverName!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppColors.accentBlue.withValues(alpha: 0.15)
                      : AppColors.inputDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.labelRu,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUpcoming ? AppColors.accentBlue : AppColors.textGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
