import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/data/models/rating_model.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/widgets/driver_rating_dialog.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/presentation/widgets/passenger_rating_dialog.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class RatingSubmission {
  RatingSubmission._();

  static Future<bool> rateDriver({
    required BuildContext context,
    required int driverProfileId,
    required String driverName,
  }) async {
    final result = await showDriverRatingDialog(
      context: context,
      driverProfileId: driverProfileId,
      driverName: driverName,
    );
    if (result == null || !context.mounted) {
      return false;
    }

    try {
      final response =
          await AppDependencies.instance.ratingsRepository.createRating(
        RatingCreateParams(
          driverProfileId: result.driverProfileId,
          rating: result.rating,
          comment: result.comment,
        ),
      );
      if (!context.mounted) {
        return false;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Спасибо за оценку!',
            ),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      return true;
    } catch (_) {
      if (!context.mounted) {
        return false;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось отправить оценку')),
        );
      return false;
    }
  }

  static Future<bool> ratePassenger({
    required BuildContext context,
    required int passengerProfileId,
    required String passengerName,
  }) async {
    final result = await showPassengerRatingDialog(
      context: context,
      passengerProfileId: passengerProfileId,
      passengerName: passengerName,
    );
    if (result == null || !context.mounted) {
      return false;
    }

    if (!context.mounted) {
      return false;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Спасибо за оценку попутчика!'),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    return true;
  }
}

bool isRideFinished(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) {
    return false;
  }
  final rideDate = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  return !rideDate.isAfter(todayDate);
}

Future<Set<int>> loadRatedDriverIds() async {
  try {
    final ratings =
        await AppDependencies.instance.ratingsRepository.getMyRatings();
    return ratings.map((RatingModel r) => r.driverProfileId).toSet();
  } catch (_) {
    return <int>{};
  }
}
