import 'package:flutter/material.dart';
import "package:tripify/core/theme/app_colors.dart";
import 'package:tripify/domain/models/booking.dart';

class TripSummaryDialog extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const TripSummaryDialog({
    super.key,
    required this.booking,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      backgroundColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.luggage_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Resumen del Viaje',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SummaryRow(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                label: 'Nombre',
                value: booking.fullName.isEmpty
                    ? 'No especificado'
                    : booking.fullName,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.mail_outline_rounded,
                iconColor: AppColors.primary,
                label: 'Correo',
                value: booking.email.isEmpty
                    ? 'No especificado'
                    : booking.email,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.location_on_outlined,
                iconColor: AppColors.primary,
                label: 'Destino',
                value: booking.destination,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.directions_bus_outlined,
                iconColor: AppColors.primary,
                label: 'Transporte',
                value: booking.transport,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.star_border_rounded,
                iconColor: AppColors.primary,
                label: 'Extras',
                value: booking.formattedExtras,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.notifications_none_rounded,
                iconColor: AppColors.primary,
                label: 'Notificaciones',
                value: booking.receiveNotifications
                    ? 'Activadas'
                    : 'Desactivadas',
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.attach_money_rounded,
                iconColor: AppColors.primary,
                label: 'Presupuesto',
                value: '\$${booking.budget.toInt()}',
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                label: 'Fecha',
                value: booking.formattedDate.isEmpty
                    ? 'No seleccionada'
                    : booking.formattedDate,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
