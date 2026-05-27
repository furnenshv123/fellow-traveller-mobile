import 'package:fellow_traveller_mobile/core/features/driver/presentation/bloc/driver_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/point_search_field.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/widgets/ride_card.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  PointModel? _from;
  PointModel? _to;
  String? _dateIso;
  final _timeController = TextEditingController(text: '09:00');
  final _seatsController = TextEditingController(text: '3');
  final _priceController = TextEditingController(text: '5000');

  @override
  void dispose() {
    _timeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
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
    context.read<DriverHomeBloc>().add(
          DriverHomeRideSubmitted(
            from: _from,
            to: _to,
            dateIso: _dateIso,
            time: _timeController.text.trim(),
            seats: int.tryParse(_seatsController.text.trim()) ?? 0,
            price: double.tryParse(_priceController.text.trim()) ?? 0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        title: const Text(
          'Создать поездку',
          style: TextStyle(
            color: AppColors.textVeryLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
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
                      onChanged: (PointModel? v) => setState(() => _from = v),
                    ),
                    const SizedBox(height: 12),
                    PointSearchField(
                      key: ValueKey<String>('to_${_to?.id}'),
                      label: 'Куда',
                      hint: 'куда',
                      value: _to,
                      icon: Icons.flag_outlined,
                      onChanged: (PointModel? v) => setState(() => _to = v),
                    ),
                    const SizedBox(height: 12),
                    _labeledField(
                      label: 'Дата',
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: _inputShell(
                          child: Text(
                            _formatDisplayDate(_dateIso),
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _labeledField(
                      label: 'Время (ЧЧ:ММ)',
                      child: TextField(
                        controller: _timeController,
                        style: const TextStyle(color: AppColors.textLight),
                        decoration: _fieldDecoration(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _labeledField(
                            label: 'Места',
                            child: TextField(
                              controller: _seatsController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textLight),
                              decoration: _fieldDecoration(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _labeledField(
                            label: 'Цена, ₸',
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textLight),
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
                        backgroundColor: AppColors.accentBlue,
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
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 10),
                RideCard(ride: ready.lastCreatedRide!),
              ],
            ],
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

  Widget _inputShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.inputDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
