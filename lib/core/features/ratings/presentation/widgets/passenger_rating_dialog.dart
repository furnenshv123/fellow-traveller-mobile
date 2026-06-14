import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class PassengerRatingResult {
  const PassengerRatingResult({
    required this.passengerProfileId,
    required this.rating,
    this.comment,
  });

  final int passengerProfileId;
  final int rating;
  final String? comment;
}

Future<PassengerRatingResult?> showPassengerRatingDialog({
  required BuildContext context,
  required int passengerProfileId,
  required String passengerName,
}) {
  return showDialog<PassengerRatingResult>(
    context: context,
    builder: (BuildContext context) => _PassengerRatingDialog(
      passengerProfileId: passengerProfileId,
      passengerName: passengerName,
    ),
  );
}

class _PassengerRatingDialog extends StatefulWidget {
  const _PassengerRatingDialog({
    required this.passengerProfileId,
    required this.passengerName,
  });

  final int passengerProfileId;
  final String passengerName;

  @override
  State<_PassengerRatingDialog> createState() => _PassengerRatingDialogState();
}

class _PassengerRatingDialogState extends State<_PassengerRatingDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      PassengerRatingResult(
        passengerProfileId: widget.passengerProfileId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusLg)),
      title: const Text(
        'Оценить попутчика',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.passengerName,
              style: const TextStyle(
                color: AppColors.textBody,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(5, (int index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starValue),
                  icon: Icon(
                    starValue <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accentAmber,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Комментарий (необязательно)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
              ),
              style: const TextStyle(color: AppColors.textBody),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Позже'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Отправить'),
        ),
      ],
    );
  }
}
