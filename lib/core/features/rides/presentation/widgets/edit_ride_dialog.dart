import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

Future<RideUpdateParams?> showEditRideDialog({
  required BuildContext context,
  required RideModel ride,
}) {
  return showDialog<RideUpdateParams>(
    context: context,
    builder: (BuildContext context) => _EditRideDialog(ride: ride),
  );
}

class _EditRideDialog extends StatefulWidget {
  const _EditRideDialog({required this.ride});

  final RideModel ride;

  @override
  State<_EditRideDialog> createState() => _EditRideDialogState();
}

class _EditRideDialogState extends State<_EditRideDialog> {
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _placesController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.ride.date);
    _timeController = TextEditingController(text: widget.ride.time);
    _placesController =
        TextEditingController(text: widget.ride.availablePlaces.toString());
    _priceController =
        TextEditingController(text: widget.ride.price.toInt().toString());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _placesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      RideUpdateParams(
        fromPointId: widget.ride.fromPoint.id,
        toPointId: widget.ride.toPoint.id,
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        availablePlaces: int.tryParse(_placesController.text.trim()),
        price: double.tryParse(_priceController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusLg)),
      title: const Text(
        'Редактировать поездку',
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
              widget.ride.routeLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _field('Дата (YYYY-MM-DD)', _dateController),
            const SizedBox(height: 12),
            _field('Время', _timeController),
            const SizedBox(height: 12),
            _field('Свободных мест', _placesController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _field('Цена', _priceController, keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
              borderSide: const BorderSide(color: AppColors.inputFocused),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(color: AppColors.textBody),
        ),
      ],
    );
  }
}
