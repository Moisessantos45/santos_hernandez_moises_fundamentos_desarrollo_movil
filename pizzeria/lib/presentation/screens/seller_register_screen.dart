import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/seller/seller_dashboard_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerRegisterScreen extends ConsumerStatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  ConsumerState<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends ConsumerState<SellerRegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<String?> _nameErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _restaurantErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _emailErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _generalErrorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _fullNameController.dispose();
    _restaurantNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameErrorNotifier.dispose();
    _restaurantErrorNotifier.dispose();
    _emailErrorNotifier.dispose();
    _passwordErrorNotifier.dispose();
    _isLoadingNotifier.dispose();
    _generalErrorNotifier.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _nameErrorNotifier.value = FormValidators.requiredField(
      _fullNameController.text,
      'Ingresa tu nombre completo',
    );
    _restaurantErrorNotifier.value = FormValidators.requiredField(
      _restaurantNameController.text,
      'Ingresa el nombre de tu pizzería',
    );
    _emailErrorNotifier.value = FormValidators.email(_emailController.text);
    _passwordErrorNotifier.value = FormValidators.password(_passwordController.text);

    return _nameErrorNotifier.value == null &&
        _restaurantErrorNotifier.value == null &&
        _emailErrorNotifier.value == null &&
        _passwordErrorNotifier.value == null;
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;

    _isLoadingNotifier.value = true;
    _generalErrorNotifier.value = null;

    try {
      await ref.read(authProvider.notifier).signUpSeller(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            restaurantName: _restaurantNameController.text.trim(),
          );

      if (!mounted) return;
      CustomNavigator.pushAndRemoveUntilFade(
        context,
        const SellerDashboardScreen(),
      );
    } catch (e) {
      _generalErrorNotifier.value = e.toString().replaceAll('Exception: ', '');
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
            final horizontalPadding = isLandscape ? 80.0 : 24.0;

            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    const PizzaLogo(size: 72),
                    const SizedBox(height: 12),
                    const Text(
                      'Portal de Vendedores',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Registra tu pizzería y gestiona tus pedidos en tiempo real',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<String?>(
                      valueListenable: _generalErrorNotifier,
                      builder: (context, error, _) {
                        if (error == null) return const SizedBox.shrink();
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
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
                                label: 'Nombre del Propietario / Encargado',
                                hintText: 'Ej. Marco Rossi',
                                prefixIcon: Icons.person_outline,
                                errorText: err,
                                onChanged: (_) => _nameErrorNotifier.value = null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<String?>(
                            valueListenable: _restaurantErrorNotifier,
                            builder: (context, err, _) {
                              return CustomTextField(
                                controller: _restaurantNameController,
                                label: 'Nombre de la Pizzería',
                                hintText: 'Ej. Pizzería Bella Napoli',
                                prefixIcon: Icons.storefront_outlined,
                                errorText: err,
                                onChanged: (_) => _restaurantErrorNotifier.value = null,
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
                                hintText: 'negocio@pizzeria.com',
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
                          const SizedBox(height: 24),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isLoadingNotifier,
                            builder: (context, isLoading, _) {
                              return CustomButton(
                                text: 'Registrar Mi Pizzería',
                                isLoading: isLoading,
                                onPressed: _handleRegister,
                              );
                            },
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
