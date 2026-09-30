import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/main_navigation_screen.dart';
import 'package:pizzeria/presentation/screens/register_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_dashboard_screen.dart';
import 'package:pizzeria/presentation/screens/seller_register_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<String?> _emailErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _generalErrorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailErrorNotifier.dispose();
    _passwordErrorNotifier.dispose();
    _isLoadingNotifier.dispose();
    _generalErrorNotifier.dispose();
    super.dispose();
  }

  bool _validate() {
    _emailErrorNotifier.value = FormValidators.email(_emailController.text);
    _passwordErrorNotifier.value = FormValidators.password(_passwordController.text);

    return _emailErrorNotifier.value == null && _passwordErrorNotifier.value == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;

    _isLoadingNotifier.value = true;
    _generalErrorNotifier.value = null;

    try {
      final userProfile = await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (userProfile.isSeller) {
        CustomNavigator.pushAndRemoveUntilFade(
          context,
          const SellerDashboardScreen(),
        );
      } else {
        CustomNavigator.pushAndRemoveUntilFade(
          context,
          const MainNavigationScreen(),
        );
      }
    } catch (e) {
      _generalErrorNotifier.value =
          e.toString().replaceAll('Exception: ', 'Error al iniciar sesión: ');
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isTablet =
                constraints.maxWidth >= 600 &&
                constraints.maxHeight >= 600 &&
                constraints.maxWidth < 1024;

            final horizontalPadding = isTablet || isLandscape ? 80.0 : 24.0;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const PizzaLogo(size: 80),
                        const SizedBox(height: 14),
                        const Text(
                          'PizzApp',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Inicia sesión para continuar tu antojo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.bannerRed,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<String?>(
                          valueListenable: _generalErrorNotifier,
                          builder: (context, error, _) {
                            if (error == null) return const SizedBox.shrink();
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ValueListenableBuilder<String?>(
                                valueListenable: _emailErrorNotifier,
                                builder: (context, err, _) {
                                  return CustomTextField(
                                    controller: _emailController,
                                    label: 'Correo Electrónico',
                                    hintText: 'correo@ejemplo.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    errorText: err,
                                    onChanged: (_) => _emailErrorNotifier.value = null,
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              ValueListenableBuilder<String?>(
                                valueListenable: _passwordErrorNotifier,
                                builder: (context, err, _) {
                                  return CustomTextField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    hintText: 'Ingresa tu contraseña',
                                    prefixIcon: Icons.lock_outline,
                                    isPassword: true,
                                    errorText: err,
                                    onChanged: (_) => _passwordErrorNotifier.value = null,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              ValueListenableBuilder<bool>(
                                valueListenable: _isLoadingNotifier,
                                builder: (context, isLoading, _) {
                                  return CustomButton(
                                    text: 'Entrar a PizzApp',
                                    isLoading: isLoading,
                                    onPressed: _handleLogin,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '¿No tienes cuenta de comprador? ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      CustomNavigator.pushFade(
                                        context,
                                        const RegisterScreen(),
                                      );
                                    },
                                    child: const Text(
                                      'REGÍSTRATE',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.bannerRed,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  CustomNavigator.pushFade(
                                    context,
                                    const SellerRegisterScreen(),
                                  );
                                },
                                child: const Text(
                                  '¿Tienes una pizzería? Regístrate como vendedor aquí',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
