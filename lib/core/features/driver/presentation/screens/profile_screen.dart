import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/components/custom_button.dart';
import 'package:fellow_traveller_mobile/core/components/editable_profile_avatar.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/driver_profile_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/logout_navigation.dart';
import 'package:fellow_traveller_mobile/core/utils/role_switch_navigation.dart';
import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late Future<DriverProfileModel?> _profileFuture;
  bool _isSwitchingRole = false;
  String? _photoUrlOverride;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _photoUrlOverride = null;
    _profileFuture = AppDependencies.instance.profileRepository
        .getDriverProfile();
  }

  Future<void> _switchRole() async {
    if (_isSwitchingRole) {
      return;
    }

    setState(() => _isSwitchingRole = true);
    await RoleSwitchNavigation.switchToOppositeRole(context);
    if (mounted) {
      setState(() => _isSwitchingRole = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppScreenBody(
        withBottomNav: true,
        child: FutureBuilder<DriverProfileModel?>(
        future: _profileFuture,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<DriverProfileModel?> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final profile = snapshot.data;

              if (profile == null) {
                return const Center(
                  child: Text(
                    'Профиль не найден',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(_load);
                  await _profileFuture;
                },
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _header(profile, _photoUrlOverride),
                    const SizedBox(height: 12),
                    _section(
                      title: 'Контакты',
                      rows: <_Row>[_Row('Телефон', profile.phone ?? '—')],
                    ),
                    const SizedBox(height: 12),
                    _section(
                      title: 'Автомобиль',
                      rows: <_Row>[
                        _Row('Модель', profile.carModel ?? '—'),
                        _Row('Цвет', profile.carColor ?? '—'),
                        _Row('Госномер', profile.carLicense ?? '—'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: AppDependencies.instance.userSession.isDriver
                          ? 'Стать попутчиком'
                          : 'Стать водителем',
                      onPressed: _isSwitchingRole ? () {} : _switchRole,
                      backgroundColor: _isSwitchingRole
                          ? AppColors.inputBorder
                          : AppColors.primary,
                    ),
                    if (_isSwitchingRole) ...<Widget>[
                      const SizedBox(height: 12),
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
                    const SizedBox(height: 20),
                    FilledButton.tonal(
                      onPressed: () => LogoutNavigation.confirmAndLogout(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surfaceMuted,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
            },
      ),
      ),
    );
  }

  Widget _header(DriverProfileModel profile, String? photoUrlOverride) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          EditableProfileAvatar(
            photoUrl: photoUrlOverride ?? profile.photoUrl,
            fallbackLetter: (profile.fullName ?? 'В')[0],
            onPhotoChanged: (String? photoUrl) {
              setState(() => _photoUrlOverride = photoUrl);
            },
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName ?? 'Водитель',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: AppColors.accentAmber,
              ),
              const SizedBox(width: 6),
              Text(
                profile.avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<_Row> rows}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (_Row row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    row.label,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(
                      color: AppColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);

  final String label;
  final String value;
}
