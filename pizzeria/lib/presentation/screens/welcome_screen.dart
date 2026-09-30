import 'package:flutter/material.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/screens/login_screen.dart';
import 'package:pizzeria/presentation/screens/register_screen.dart';
import 'package:pizzeria/presentation/screens/seller_register_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              child: isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&auto=format&fit=crop&q=80',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                cacheWidth: 800,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.inputBackground,
                                  child: const Center(
                                    child: Icon(
                                      Icons.local_pizza,
                                      size: 100,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 20,
                            ),
                            child: _welcomeActions(context),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Text(
                            'PizzApp',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&auto=format&fit=crop&q=80',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                cacheWidth: 800,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.inputBackground,
                                  child: const Center(
                                    child: Icon(
                                      Icons.local_pizza,
                                      size: 100,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 16,
                            ),
                            child: _welcomeActions(context),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _welcomeActions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¡Bienvenido a\nPizzApp!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Las mejores pizzas artesanales y pizzerías locales a la puerta de tu casa.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        const Spacer(),
        CustomButton(
          text: 'Iniciar Sesión',
          onPressed: () {
            CustomNavigator.pushFade(
              context,
              const LoginScreen(),
            );
          },
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Crear Cuenta',
          variant: ButtonVariant.outlined,
          onPressed: () {
            CustomNavigator.pushFade(
              context,
              const RegisterScreen(),
            );
          },
        ),
        const SizedBox(height: 10),
        CustomButton(
          text: '¿Tienes una pizzería? Regístrate aquí',
          variant: ButtonVariant.text,
          textColor: AppColors.bannerRed,
          onPressed: () {
            CustomNavigator.pushFade(
              context,
              const SellerRegisterScreen(),
            );
          },
        ),
      ],
    );
  }
}
