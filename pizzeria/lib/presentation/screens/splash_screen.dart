import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/core/bootstrap/app_bootstrap.dart';
import 'package:pizzeria/core/config/app_config.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/screens/error_init_screen.dart';
import 'package:pizzeria/presentation/screens/main_navigation_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_dashboard_screen.dart';
import 'package:pizzeria/presentation/screens/welcome_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    if (AppConfig.isSupabaseConfigured && !AppBootstrap.isReady) {
      CustomNavigator.pushReplacementFade(
        context,
        ErrorInitScreen(
          onRetry: () async {
            await AppBootstrap.init();
            if (mounted) _checkSessionAndNavigate();
          },
        ),
      );
      return;
    }

    try {
      var userProfile = ref.read(authProvider).value;
      userProfile ??= await ref.read(authProvider.future);

      if (userProfile == null) {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser ?? client.auth.currentSession?.user;
        if (user != null) {
          userProfile = await ref.read(authDatasourceProvider).getCurrentUserProfile();
        }
      }

      if (!mounted) return;

      if (userProfile != null) {
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
        return;
      }
    } catch (_) {}

    if (mounted) {
      CustomNavigator.pushAndRemoveUntilFade(
        context,
        const WelcomeScreen(),
      );
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
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    const PizzaLogo(size: 130),
                    const SizedBox(height: 24),
                    const Text(
                      'PizzApp',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(flex: 2),
                    const DashedOvenLoader(size: 70),
                    const SizedBox(height: 16),
                    const Text(
                      'Preparando el Horno',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bannerRed,
                      ),
                    ),
                    const Spacer(flex: 3),
                    const Text(
                      'Todos los derechos reservados @2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
