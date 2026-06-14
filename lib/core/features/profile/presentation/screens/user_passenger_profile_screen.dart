import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/passenger_profile_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/phone_launcher.dart';
import 'package:fellow_traveller_mobile/core/utils/photo_url_resolver.dart';
import 'package:flutter/material.dart';

class UserPassengerProfileScreen extends StatefulWidget {
  const UserPassengerProfileScreen({
    required this.profileId,
    super.key,
  });

  final int profileId;

  @override
  State<UserPassengerProfileScreen> createState() =>
      _UserPassengerProfileScreenState();
}

class _UserPassengerProfileScreenState extends State<UserPassengerProfileScreen> {
  late Future<PassengerProfileModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _profileFuture = AppDependencies.instance.profileRepository
        .getPassengerProfileById(widget.profileId);
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    final launched = await PhoneLauncher.call(phone);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть приложение для звонка'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Профиль попутчика'),
      ),
      body: AppScreenBody(
        includeTopInset: false,
        child: FutureBuilder<PassengerProfileModel?>(
          future: _profileFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<PassengerProfileModel?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Не удалось загрузить профиль',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => setState(_load),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                      backgroundImage: PhotoUrlResolver.resolve(profile.photoUrl) !=
                              null
                          ? NetworkImage(
                              PhotoUrlResolver.resolve(profile.photoUrl)!,
                            )
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
                      profile.fullName ?? 'Попутчик',
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
                    if (profile.phone != null &&
                        profile.phone!.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _callPhone(context, profile.phone!),
                        icon: const Icon(Icons.phone_rounded),
                        label: const Text('Связаться с попутчиком'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
