import 'package:flutter/material.dart';
import 'package:pizzeria/presentation/widgets/custom_button.dart';
import 'package:pizzeria/theme/app_colors.dart';

class ErrorInitScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const ErrorInitScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: AppColors.bannerRed,
              ),
              const SizedBox(height: 20),
              const Text(
                'Error de Configuración',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No se pudo establecer conexión con los servicios de Supabase. Verifica tu archivo env.dev.json y las credenciales del proyecto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              if (onRetry != null)
                CustomButton(
                  text: 'Reintentar',
                  width: 200,
                  onPressed: onRetry,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
