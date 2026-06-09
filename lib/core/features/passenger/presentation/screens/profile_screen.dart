import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/passenger_profile_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/logout_navigation.dart';
import 'package:fellow_traveller_mobile/core/utils/role_switch_navigation.dart';
import 'package:flutter/material.dart';
import 'package:fellow_traveller_mobile/core/components/custom_button.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  late Future<PassengerProfileModel?> _profileFuture;
  bool _isSwitchingRole = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _profileFuture = AppDependencies.instance.profileRepository
        .getPassengerProfile();
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
        child: FutureBuilder<PassengerProfileModel?>(
        future: _profileFuture,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<PassengerProfileModel?> snapshot,
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
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppColors.radiusLg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: profile.photoUrl != null
                                ? NetworkImage(profile.photoUrl!)
                                : null,
                            child: profile.photoUrl == null
                                ? Text(
                                    (profile.fullName ?? 'П')[0],
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.fullName ?? 'Пассажир',
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Телефон',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                              Text(
                                profile.phone ?? '—',
                                style: const TextStyle(
                                  color: AppColors.textBody,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

                    const SizedBox(height: 12),
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
}
