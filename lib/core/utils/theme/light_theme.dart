import 'dart:ui';

import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:fellow_traveller_mobile/core/utils/theme/theme_implementation.dart';

class LightTheme implements ThemeImplementation {
  @override
  Color get approSecondary => AppColors.primaryColor;

  @override
  Color get welcomeBackgroundColor => AppColors.backgroundColor;

  @override
  String get bgMain => 'assets/images/bg_img.png';

  @override
  String get fellowPeople => 'assets/images/fellow-people.svg';

  @override
  String get altAvatar => 'assets/images/alt-avatar.svg';

  @override
  Color get monoFormive => AppColors.grayColor;

  @override
  Color get systemGray => AppColors.grayColor;

  @override
  Color get deepKupol => AppColors.grayColor;

  @override
  Color get monoWhyWhite => AppColors.grayColor;

  @override
  Color get deepGlobo => AppColors.grayColor;

  @override
  Color get deepAppro => AppColors.grayColor;

  @override
  Color get blueOblak => AppColors.primaryColor;

  @override
  Color get blueSkuka => AppColors.primaryColor;

  final blueLogo = AppColors.primaryColor;

  @override
  Color get addonsAgtung => AppColors.primaryColor;

  @override
  Color get deepLighta => AppColors.primaryColor;

  @override
  Color get blueKrak => AppColors.primaryColor;

  @override
  Color get primarySula => AppColors.primaryColor;

  @override
  Color get deepLogo => AppColors.primaryColor;

  @override
  Color get bottomSheetBackground => AppColors.moonLightBlueColor;
}
