import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/main_navigation_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<String?> _nameErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _emailErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _termsNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _generalErrorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameErrorNotifier.dispose();
    _emailErrorNotifier.dispose();
    _passwordErrorNotifier.dispose();
    _termsNotifier.dispose();
    _isLoadingNotifier.dispose();
    _generalErrorNotifier.dispose();
    super.dispose();
  }

  bool _validate() {
    _nameErrorNotifier.value = FormValidators.requiredField(
      _fullNameController.text,
      'Ingresa tu nombre completo',
    );
    _emailErrorNotifier.value = FormValidators.email(_emailController.text);
    _passwordErrorNotifier.value = FormValidators.password(_passwordController.text);

    return _nameErrorNotifier.value == null &&
        _emailErrorNotifier.value == null &&
        _passwordErrorNotifier.value == null;
  }

  Future<void> _handleRegister() async {
    if (!_validate()) return;
    if (!_termsNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
        ),
      );
      return;
    }

    _isLoadingNotifier.value = true;
    _generalErrorNotifier.value = null;

    try {
      await ref.read(authProvider.notifier).signUpBuyer(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          );

      if (!mounted) return;
      CustomNavigator.pushAndRemoveUntilFade(
        context,
        const MainNavigationScreen(),
      );
    } catch (e) {
      _generalErrorNotifier.value =
          e.toString().replaceAll('Exception: ', 'Error al registrar: ');
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Únete a la familia',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bannerRed,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Crea tu cuenta de comprador y empieza a disfrutar de las mejores pizzas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
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
                            valueListenable: _nameErrorNotifier,
                            builder: (context, err, _) {
                              return CustomTextField(
                                controller: _fullNameController,
                                label: 'Nombre Completo',
                                hintText: 'Ingresa tu nombre y apellido',
                                prefixIcon: Icons.person_outline,
                                errorText: err,
                                onChanged: (_) => _nameErrorNotifier.value = null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: _emailErrorNotifier,
                            builder: (context, err, _) {
                              return CustomTextField(
                                controller: _emailController,
                                label: 'Correo Electrónico',
                                hintText: 'usuario@email.com',
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                errorText: err,
                                onChanged: (_) => _emailErrorNotifier.value = null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: _passwordErrorNotifier,
                            builder: (context, err, _) {
                              return CustomTextField(
                                controller: _passwordController,
                                label: 'Contraseña',
                                hintText: 'Mínimo 6 caracteres',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                errorText: err,
                                onChanged: (_) => _passwordErrorNotifier.value = null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<bool>(
                            valueListenable: _termsNotifier,
                            builder: (context, accepted, _) {
                              return GestureDetector(
                                onTap: () {
                                  _termsNotifier.value = !accepted;
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: accepted
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                        color: accepted
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                      child: accepted
                                          ? const Icon(
                                              Icons.check,
                                              size: 13,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Acepto los términos y condiciones y la política de privacidad.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textPrimary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isLoadingNotifier,
                            builder: (context, isLoading, _) {
                              return CustomButton(
                                text: 'Crear Mi Cuenta',
                                isLoading: isLoading,
                                onPressed: _handleRegister,
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿Ya tienes cuenta? ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Inicia sesión',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.bannerRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
