import 'package:fellow_traveller_mobile/core/features/driver/presentation/bloc/driver_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/point_search_field.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/ride_card.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/formatters/time_formatter.dart';
import 'package:fellow_traveller_mobile/core/utils/validators/ride_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  PointModel? _from;
  PointModel? _to;
  String? _dateIso;
  final _timeController = TextEditingController(text: '09:00');
  final _seatsController = TextEditingController(text: '3');
  final _priceController = TextEditingController(text: '5000');
  final _dateDisplayController = TextEditingController();
  String? _routeError;

  @override
  void dispose() {
    _timeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _dateDisplayController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dateIso != null
        ? DateTime.tryParse(_dateIso!) ?? now
        : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ru', 'RU'),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _dateIso =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dateDisplayController.text = _formatDisplayDate(_dateIso);
    });
  }

  String _formatDisplayDate(String? iso) {
    if (iso == null || iso.isEmpty) {
      return 'Выберите дату';
    }
    final parts = iso.split('-');
    if (parts.length != 3) {
      return iso;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  void _submit() {
    setState(() {
      _routeError = RideValidators.routePoints(
        fromId: _from?.id,
        toId: _to?.id,
      );
    });

    if (!_formKey.currentState!.validate() || _routeError != null) {
      return;
    }

    context.read<DriverHomeBloc>().add(
          DriverHomeRideSubmitted(
            from: _from,
            to: _to,
            dateIso: _dateIso,
            time: _timeController.text.trim(),
            seats: int.parse(_seatsController.text.trim()),
            price: double.parse(
              _priceController.text.trim().replaceAll(',', '.'),
            ),
          ),
        );
  }

  String? _validateDateField(String? _) => RideValidators.dateIso(_dateIso);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      
      body: BlocConsumer<DriverHomeBloc, DriverHomeState>(
        listener: (BuildContext context, DriverHomeState state) {
          if (state is DriverHomeReady) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
            }
          }
        },
        builder: (BuildContext context, DriverHomeState state) {
          final ready = state is DriverHomeReady ? state : const DriverHomeReady();

          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Укажите маршрут и параметры поездки. Пассажиры найдут вас по дате и направлению.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    PointSearchField(
                      key: ValueKey<String>('from_${_from?.id}'),
                      label: 'Откуда',
                      hint: 'откуда',
                      value: _from,
                      onChanged: (PointModel? v) => setState(() {
                        _from = v;
                        _routeError = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    PointSearchField(
                      key: ValueKey<String>('to_${_to?.id}'),
                      label: 'Куда',
                      hint: 'куда',
                      value: _to,
                      icon: Icons.flag_outlined,
                      onChanged: (PointModel? v) => setState(() {
                        _to = v;
                        _routeError = null;
                      }),
                    ),
                    if (_routeError != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _routeError!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _labeledField(
                      label: 'Дата',
                      child: TextFormField(
                        readOnly: true,
                        onTap: _pickDate,
                        controller: _dateDisplayController,
                        validator: _validateDateField,
                        style: const TextStyle(
                          color: AppColors.textBody,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _fieldDecoration(hint: 'Выберите дату'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _labeledField(
                      label: 'Время (ЧЧ:ММ)',
                      child: TextFormField(
                        controller: _timeController,
                        style: const TextStyle(color: AppColors.textBody),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          TimeInputFormatter(),
                        ],
                        validator: RideValidators.time,
                        decoration: _fieldDecoration(hint: '09:00'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _labeledField(
                            label: 'Места',
                            child: TextFormField(
                              controller: _seatsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: RideValidators.seats,
                              style: const TextStyle(color: AppColors.textBody),
                              decoration: _fieldDecoration(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledField(
                            label: 'Цена, Br',
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.,]'),
                                ),
                              ],
                              validator: RideValidators.price,
                              style: const TextStyle(color: AppColors.textBody),
                              decoration: _fieldDecoration(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: ready.isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: ready.isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Опубликовать поездку',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ],
                ),
              ),
              if (ready.lastCreatedRide != null) ...<Widget>[
                const SizedBox(height: 24),
                const Text(
                  'Последняя поездка',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                RideCard(ride: ready.lastCreatedRide!),
              ],
            const SizedBox(height: 100),
            ],
          ),
          );
        },
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
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
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputFocused),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
