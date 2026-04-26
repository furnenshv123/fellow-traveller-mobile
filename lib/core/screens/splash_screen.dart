import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _titleOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _logoOpacity = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) {
        return;
      }
      context.go(AppRoutesEnum.main.path);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF0D3254),
              Color(0xFF1A5A8E),
              Color(0xFF103452),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(
                                0xFF1A84FF,
                              ).withValues(alpha: 0.45),
                              blurRadius: 34,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: SvgPicture.asset('assets/images/logo.svg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SlideTransition(
                    position: _titleOffset,
                    child: const Text(
                      'Poputka',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Твоя дорога, твоя компания',
                    style: TextStyle(
                      color: Color(0xCFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
