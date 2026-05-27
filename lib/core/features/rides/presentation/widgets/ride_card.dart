import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class RideCard extends StatelessWidget {
  const RideCard({
    required this.ride,
    this.onTap,
    this.trailing,
    this.subtitle,
    super.key,
  });

  final RideModel ride;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car, color: AppColors.accentBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ride.routeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? _defaultSubtitle(ride),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Text(
                    '${ride.price.toInt()} ₸',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  String _defaultSubtitle(RideModel ride) {
    final parts = <String>[
      _formatDisplayDate(ride.date),
      ride.time,
      if (ride.driverName != null) ride.driverName!,
      '${ride.availablePlaces} мест',
    ];
    return parts.where((String s) => s.isNotEmpty).join(' · ');
  }

  String _formatDisplayDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) {
      return isoDate;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }
}
