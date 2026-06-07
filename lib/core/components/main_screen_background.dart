import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

class MainScreenBackground extends StatelessWidget {
  const MainScreenBackground({super.key});

  static const String assetPath = 'assets/images/bg_img.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white.withValues(alpha: 0.55),
                AppColors.primaryLight.withValues(alpha: 0.35),
                AppColors.scaffoldDark.withValues(alpha: 0.55),
              ],
              stops: <double>[0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
