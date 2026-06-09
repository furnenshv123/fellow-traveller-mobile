import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/driver_profile_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class UserDriverProfileScreen extends StatefulWidget {
  const UserDriverProfileScreen({
    required this.profileId,
    super.key,
  });

  final int profileId;

  @override
  State<UserDriverProfileScreen> createState() =>
      _UserDriverProfileScreenState();
}

class _UserDriverProfileScreenState extends State<UserDriverProfileScreen> {
  late Future<DriverProfileModel?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _profileFuture = AppDependencies.instance.profileRepository
        .getDriverProfileById(widget.profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Профиль водителя'),
      ),
      body: AppScreenBody(
        includeTopInset: false,
        child: FutureBuilder<DriverProfileModel?>(
          future: _profileFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<DriverProfileModel?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return _ErrorState(onRetry: () => setState(_load));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _header(profile),
                  const SizedBox(height: 12),
                  _infoCard(
                    title: 'Контакты',
                    rows: <_InfoRow>[
                      _InfoRow('Телефон', profile.phone ?? '—'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    title: 'Автомобиль',
                    rows: <_InfoRow>[
                      _InfoRow('Модель', profile.carModel ?? '—'),
                      _InfoRow('Цвет', profile.carColor ?? '—'),
                      _InfoRow('Госномер', profile.carLicense ?? '—'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(DriverProfileModel profile) {
    return Container(
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
                    (profile.fullName ?? 'В')[0],
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

  Widget _infoCard({required String title, required List<_InfoRow> rows}) {
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
            (_InfoRow row) => Padding(
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;
}
