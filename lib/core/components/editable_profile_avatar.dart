import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/errors/api_error_mapper.dart';
import 'package:fellow_traveller_mobile/core/utils/app_bottom_sheet.dart' show showAppBottomSheet;
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/photo_url_resolver.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditableProfileAvatar extends StatefulWidget {
  const EditableProfileAvatar({
    super.key,
    required this.fallbackLetter,
    this.photoUrl,
    this.radius = 48,
    this.onPhotoChanged,
  });

  final String? photoUrl;
  final String fallbackLetter;
  final double radius;
  final ValueChanged<String?>? onPhotoChanged;

  @override
  State<EditableProfileAvatar> createState() => _EditableProfileAvatarState();
}

class _EditableProfileAvatarState extends State<EditableProfileAvatar> {
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;

  String? get _resolvedPhotoUrl => PhotoUrlResolver.resolve(widget.photoUrl);

  Future<void> _showOptions() async {
    if (_isUpdating) {
      return;
    }

    final action = await showAppBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Выбрать из галереи'),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          if (widget.photoUrl != null)
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
              title: Text(
                'Удалить фото',
                style: TextStyle(color: Colors.red.shade700),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
        ],
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'gallery') {
      await _pickFromGallery();
    } else if (action == 'delete') {
      await _deletePhoto();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null || !mounted) {
        return;
      }

      setState(() => _isUpdating = true);

      final photoUrl = await AppDependencies.instance.profileRepository
          .uploadProfilePhoto(file.path);

      if (!mounted) {
        return;
      }

      widget.onPhotoChanged?.call(photoUrl);
      _showSnackBar('Фото обновлено');
    } on DioException catch (error) {
      if (mounted) {
        _showSnackBar(ApiErrorMapper.fromDioException(error));
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Не удалось загрузить фото');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _deletePhoto() async {
    setState(() => _isUpdating = true);

    try {
      await AppDependencies.instance.profileRepository.deleteProfilePhoto();

      if (!mounted) {
        return;
      }

      widget.onPhotoChanged?.call(null);
      _showSnackBar('Фото удалено');
    } on DioException catch (error) {
      if (mounted) {
        _showSnackBar(ApiErrorMapper.fromDioException(error));
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Не удалось удалить фото');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = widget.radius * 0.38;

    return GestureDetector(
      onTap: _showOptions,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: _resolvedPhotoUrl != null
                ? NetworkImage(_resolvedPhotoUrl!)
                : null,
            child: _resolvedPhotoUrl == null
                ? Text(
                    widget.fallbackLetter,
                    style: TextStyle(
                      fontSize: widget.radius * 0.67,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          if (_isUpdating)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: SizedBox(
                width: badgeSize,
                height: badgeSize,
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: badgeSize * 0.55,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocalProfilePhotoPicker extends StatefulWidget {
  const LocalProfilePhotoPicker({
    super.key,
    required this.fallbackLetter,
    this.photoUrl,
    this.localImagePath,
    this.radius = 48,
    this.onLocalImageSelected,
  });

  final String? photoUrl;
  final String? localImagePath;
  final String fallbackLetter;
  final double radius;
  final ValueChanged<String?>? onLocalImageSelected;

  @override
  State<LocalProfilePhotoPicker> createState() => _LocalProfilePhotoPickerState();
}

class _LocalProfilePhotoPickerState extends State<LocalProfilePhotoPicker> {
  final ImagePicker _picker = ImagePicker();

  String? get _resolvedPhotoUrl => PhotoUrlResolver.resolve(widget.photoUrl);

  ImageProvider? get _imageProvider {
    if (widget.localImagePath != null) {
      return FileImage(File(widget.localImagePath!));
    }
    if (_resolvedPhotoUrl != null) {
      return NetworkImage(_resolvedPhotoUrl!);
    }
    return null;
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (file != null) {
      widget.onLocalImageSelected?.call(file.path);
    }
  }

  Future<void> _clearPhoto() async {
    widget.onLocalImageSelected?.call(null);
  }

  Future<void> _showOptions() async {
    final action = await showAppBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Выбрать из галереи'),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          if (_imageProvider != null)
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
              title: Text(
                'Убрать фото',
                style: TextStyle(color: Colors.red.shade700),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
        ],
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'gallery') {
      await _pickFromGallery();
    } else if (action == 'delete') {
      await _clearPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = widget.radius * 0.38;
    final imageProvider = _imageProvider;

    return GestureDetector(
      onTap: _showOptions,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    widget.fallbackLetter,
                    style: TextStyle(
                      fontSize: widget.radius * 0.67,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: SizedBox(
                width: badgeSize,
                height: badgeSize,
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: badgeSize * 0.55,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
