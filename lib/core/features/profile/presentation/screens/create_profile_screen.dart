import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/components/custom_button.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/errors/api_error_mapper.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/formatters/belarus_license_plate_formatter.dart';
import 'package:fellow_traveller_mobile/core/utils/formatters/belarus_phone_formatter.dart';
import 'package:fellow_traveller_mobile/core/utils/validators/profile_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carLicenseController = TextEditingController();

  bool _isLoading = false;
  String? _generalError;

  bool get _isDriver => AppDependencies.instance.userSession.isDriver;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _carLicenseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    final repo = AppDependencies.instance.profileRepository;
    final session = AppDependencies.instance.userSession;

    try {
      if (_isDriver) {
        await repo.createDriverProfile(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          carModel: _carModelController.text.trim(),
          carLicense: _carLicenseController.text.trim().toUpperCase(),
          photoUrl: _photoUrlController.text,
          carColor: _carColorController.text,
        );
      } else {
        await repo.createPassengerProfile(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          photoUrl: _photoUrlController.text,
        );
      }

      await session.setProfileComplete(true);

      if (!mounted) {
        return;
      }
      context.go(AppRoutesEnum.main.path);
    } on DioException catch (error) {
      setState(() {
        _isLoading = false;
        _generalError = ApiErrorMapper.fromDioException(error);
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _generalError = 'Не удалось сохранить профиль. Попробуйте снова.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.scaffoldDark, AppColors.scaffoldDarkMid],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppColors.radiusLg),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _isDriver
                              ? 'Профиль водителя'
                              : 'Профиль пассажира',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isDriver
                              ? 'Заполните данные, чтобы создавать поездки'
                              : 'Заполните данные, чтобы бронировать поездки',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _field(
                          label: 'ФИО *',
                          controller: _fullNameController,
                          hint: 'Иван Иванов Иванович',
                          textCapitalization: TextCapitalization.words,
                          validator: ProfileValidators.fullName,
                        ),
                        const SizedBox(height: 16),
                        _field(
                          label: 'Телефон *',
                          controller: _phoneController,
                          hint: '+375 (29) 123-45-67',
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            BelarusPhoneFormatter(),
                          ],
                          validator: ProfileValidators.phone,
                        ),
                        const SizedBox(height: 16),
                        _field(
                          label: 'Фото (URL)',
                          controller: _photoUrlController,
                          hint: 'https://...',
                        ),
                        if (_isDriver) ...<Widget>[
                          const SizedBox(height: 16),
                          _field(
                            label: 'Модель автомобиля *',
                            controller: _carModelController,
                            hint: 'Toyota Camry',
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9\s\-]'),
                              ),
                            ],
                            validator: ProfileValidators.carModel,
                          ),
                          const SizedBox(height: 16),
                          _field(
                            label: 'Цвет автомобиля',
                            controller: _carColorController,
                            hint: 'Белый',
                          ),
                          const SizedBox(height: 16),
                          _field(
                            label: 'Госномер *',
                            controller: _carLicenseController,
                            hint: '1234 AB-7',
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: <TextInputFormatter>[
                              BelarusLicensePlateFormatter(),
                            ],
                            validator: ProfileValidators.carLicense,
                          ),
                        ],
                        if (_generalError != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            _generalError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Сохранить профиль',
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: _isLoading ? () {} : _submit,
                          backgroundColor: _isLoading
                              ? AppColors.inputBorder
                              : AppColors.primary,
                        ),
                        if (_isLoading) ...<Widget>[
                          const SizedBox(height: 16),
                          const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textBody,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
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
              borderSide: const BorderSide(
                color: AppColors.inputFocused,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(color: AppColors.textBody),
        ),
      ],
    );
  }
}
