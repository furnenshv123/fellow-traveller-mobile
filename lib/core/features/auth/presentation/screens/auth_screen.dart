import 'package:flutter/material.dart';

enum _UserRole { passenger, driver }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _UserRole _selectedRole = _UserRole.passenger;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              Color(0xFFF5F5F5),
              Color(0xFFEEEEEE),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF1783FF),
                    Color(0xFF176DFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF1783FF).withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Вход',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'test1@example.com',
                      hintStyle: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Пароль',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: const Color(0xFF1783FF),
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Роль',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildRoleOption(
                          label: 'Пассажир',
                          value: _UserRole.passenger,
                          isSelected: _selectedRole == _UserRole.passenger,
                          onTap: () {
                            setState(() {
                              _selectedRole = _UserRole.passenger;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildRoleOption(
                          label: 'Водитель',
                          value: _UserRole.driver,
                          isSelected: _selectedRole == _UserRole.driver,
                          onTap: () {
                            setState(() {
                              _selectedRole = _UserRole.driver;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        color: Color(0xFF1783FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: RichText(
                        text: const TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Нет аккаунта? ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Зарегистрироваться',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String label,
    required _UserRole value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white70,
                width: 2,
              ),
            ),
            child: isSelected
                ? Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
