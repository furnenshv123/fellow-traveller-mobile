import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/formatters/time_formatter.dart';
import 'package:fellow_traveller_mobile/core/utils/validators/ride_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_dateController.text.trim()) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ru', 'RU'),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final date = _dateController.text.trim();
    final time = _timeController.text.trim();
    final places = int.parse(_placesController.text.trim());
    final price = double.parse(_priceController.text.trim().replaceAll(',', '.'));

    Navigator.of(context).pop(
      RideUpdateParams(
        fromPointId: widget.ride.fromPoint.id,
        toPointId: widget.ride.toPoint.id,
        date: date,
        time: time,
        availablePlaces: places,
        price: price,
      ),
    );
  }

  String? _validateDate(String? value) {
    return RideValidators.dateIso(value?.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
      ),
      title: const Text(
        'Редактировать поездку',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
              _dateField(),
              const SizedBox(height: 12),
              _field(
                label: 'Время (ЧЧ:ММ)',
                controller: _timeController,
                hint: '09:00',
                inputFormatters: <TextInputFormatter>[TimeInputFormatter()],
                validator: RideValidators.time,
              ),
              const SizedBox(height: 12),
              _field(
                label: 'Свободных мест',
                controller: _placesController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: RideValidators.seats,
              ),
              const SizedBox(height: 12),
              _field(
                label: 'Цена',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                validator: RideValidators.price,
              ),
            ],
          ),
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

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Дата',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _pickDate,
          validator: _validateDate,
          decoration: _inputDecoration(hint: 'Выберите дату'),
          style: const TextStyle(color: AppColors.textBody),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: _inputDecoration(hint: hint),
          style: const TextStyle(color: AppColors.textBody),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
