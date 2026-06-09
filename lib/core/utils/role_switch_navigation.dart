import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/errors/api_error_mapper.dart';
import 'package:fellow_traveller_mobile/core/utils/profile_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class RoleSwitchNavigation {
  static Future<void> switchToOppositeRole(BuildContext context) async {
    final deps = AppDependencies.instance;
    final newRole = deps.userSession.isDriver ? 'passenger' : 'driver';

    try {
      final response = await deps.authRepository.changeRole(role: newRole);
      if (!context.mounted) {
        return;
      }

      final route = await ProfileNavigation.resolvePostRoleSwitchRoute(
        authResponse: response,
      );
      if (!context.mounted) {
        return;
      }

      context.go(route);
    } on DioException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(ApiErrorMapper.fromDioException(error)),
            backgroundColor: Colors.red.shade700,
          ),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Не удалось сменить роль. Попробуйте снова.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
    }
  }
}
