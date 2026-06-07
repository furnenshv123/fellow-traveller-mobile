import 'dart:ui';

import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/theme/theme_implementation.dart';

class LightTheme implements ThemeImplementation {
  @override
  Color get approSecondary => AppColors.primary;

  @override
  Color get welcomeBackgroundColor => AppColors.background;

  @override
  String get bgMain => 'assets/images/bg_img.png';

  @override
  String get fellowPeople => 'assets/images/fellow-people.svg';

  @override
  String get altAvatar => 'assets/images/alt-avatar.svg';

  @override
  Color get monoFormive => AppColors.surfaceMuted;

  @override
  Color get systemGray => AppColors.surfaceMuted;

  @override
  Color get deepKupol => AppColors.surfaceMuted;

  @override
  Color get monoWhyWhite => AppColors.surfaceMuted;

  @override
  Color get deepGlobo => AppColors.surfaceMuted;

  @override
  Color get deepAppro => AppColors.surfaceMuted;

  @override
  Color get blueOblak => AppColors.primary;

  @override
  Color get blueSkuka => AppColors.primary;

  final blueLogo = AppColors.primary;

  @override
  Color get addonsAgtung => AppColors.primary;

  @override
  Color get deepLighta => AppColors.primary;

  @override
  Color get blueKrak => AppColors.primary;

  @override
  Color get primarySula => AppColors.primary;

  @override
  Color get deepLogo => AppColors.primary;

  @override
  Color get bottomSheetBackground => AppColors.primaryDark;
}
