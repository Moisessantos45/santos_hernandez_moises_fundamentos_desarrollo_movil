import 'package:flutter/material.dart';
import 'package:tripify/core/navigation/custom_navigator.dart';
import 'package:tripify/core/theme/app_colors.dart';
import 'package:tripify/domain/models/booking.dart';
import 'package:tripify/domain/models/trip.dart';
import 'package:tripify/presentation/widgets/widgets.dart';
import 'ticket_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final Trip? trip;

  const BookingFormScreen({super.key, this.trip});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ValueNotifier<String> _selectedDestination = ValueNotifier<String>(
    'Playa',
  );
  final ValueNotifier<String> _selectedTransport = ValueNotifier<String>(
    'Avión',
  );

  final ValueNotifier<bool> _hotelIncluded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _guidedTour = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _travelInsurance = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _notifications = ValueNotifier<bool>(true);

  final ValueNotifier<double> _budget = ValueNotifier<double>(3000.0);
  final ValueNotifier<DateTime?> _travelDate = ValueNotifier<DateTime?>(null);

  final List<String> _transportOptions = ['Avión', 'Autobús', 'Tren', 'Barco'];

  void _showFeedbackSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _selectedDestination.value = widget.trip?.category ?? 'Playa';
    _selectedTransport.value = 'Avión';
    _hotelIncluded.value = false;
    _guidedTour.value = false;
    _travelInsurance.value = false;
    _notifications.value = true;
    _budget.value = 3000.0;
    _travelDate.value = null;

    _showFeedbackSnackBar('Formulario limpiado');
  }

  bool _isFormValid() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final hasValidEmail =
        email.isNotEmpty && email.contains('@') && email.contains('.');
    final hasDate = _travelDate.value != null;

    return name.isNotEmpty && hasValidEmail && hasDate;
  }

  Booking _createBookingObject() {
    final List<String> extras = [];
    if (_hotelIncluded.value) extras.add('Hotel');
    if (_guidedTour.value) extras.add('Tour');
    if (_travelInsurance.value) extras.add('Seguro');

    return Booking(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      destination: _selectedDestination.value,
      transport: _selectedTransport.value,
      extras: extras,
      receiveNotifications: _notifications.value,
      budget: _budget.value,
      travelDate: _travelDate.value,
      tripImageUrl: widget.trip?.imageUrl,
    );
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          ValidationDialog(onDismiss: () => Navigator.pop(context)),
    );
  }

  void _showSummaryDialog() {
    if (!_isFormValid()) {
      _showValidationDialog();
      return;
    }

    final booking = _createBookingObject();

    showDialog(
      context: context,
      builder: (context) => TripSummaryDialog(
        booking: booking,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          _navigateToTicket(booking);
        },
      ),
    );
  }

  void _submitBooking() {
    if (!_isFormValid()) {
      _showValidationDialog();
      return;
    }

    final booking = _createBookingObject();
    _navigateToTicket(booking);
  }

  void _navigateToTicket(Booking booking) {
    CustomNavigator.pushFade(context, TicketScreen(booking: booking));
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _travelDate.value ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _travelDate.value = pickedDate;
      final day = pickedDate.day.toString().padLeft(2, '0');
      final month = pickedDate.month.toString().padLeft(2, '0');
      final year = pickedDate.year.toString();
      _showFeedbackSnackBar('Fecha seleccionada: $day/$month/$year');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      if (widget.trip!.category == 'Montaña' ||
          widget.trip!.category == 'Ciudad' ||
          widget.trip!.category == 'Playa') {
        _selectedDestination.value = widget.trip!.category;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _selectedDestination.dispose();
    _selectedTransport.dispose();
    _hotelIncluded.dispose();
    _guidedTour.dispose();
    _travelInsurance.dispose();
    _notifications.dispose();
    _budget.dispose();
    _travelDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _selectedDestination,
        _selectedTransport,
        _hotelIncluded,
        _guidedTour,
        _travelInsurance,
        _notifications,
        _budget,
        _travelDate,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Reserva de Viaje',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Limpiar campos',
                onPressed: _resetForm,
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    constraints.maxWidth > constraints.maxHeight;
                final isTablet =
                    constraints.maxWidth >= 600 &&
                    constraints.maxHeight >= 600 &&
                    constraints.maxWidth < 1024;

                final contentPadding = isTablet || isLandscape
                    ? const EdgeInsets.symmetric(horizontal: 48, vertical: 20)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: contentPadding,
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          SectionCard(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.primaryDark,
                            iconBgColor: AppColors.primaryLight,
                            title: 'Sección 1 · Información general',
                            subtitle: 'Completa tu reserva paso a paso',
                            child: const Text(
                              'Llena tus datos, elige destino y confirma tu viaje.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SectionCard(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF16A34A),
                            iconBgColor: const Color(0xFFDCFCE7),
                            title: 'Sección 2 · Datos del viajero',
                            subtitle: '¿Quién se va de viaje?',
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre completo',
                                    hintText: 'Ej: Ana Garcia',
                                    prefixIcon: Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'Ej: ana@correo.com',
                                    prefixIcon: Icon(
                                      Icons.mail_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SectionCard(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFFEA580C),
                            iconBgColor: const Color(0xFFFFEDD5),
                            title: 'Sección 3 · Destino y transporte',
                            subtitle: 'Elige tu aventura',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DestinationInkWellCard(
                                        icon: Icons.beach_access_rounded,
                                        label: 'Playa',
                                        activeColor: const Color(0xFF0284C7),
                                        activeBgColor: const Color(0xFFE0F2FE),
                                        isSelected:
                                            _selectedDestination.value ==
                                            'Playa',
                                        onTap: () {
                                          _selectedDestination.value = 'Playa';
                                          _showFeedbackSnackBar(
                                            'Destino seleccionado: Playa',
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _DestinationInkWellCard(
                                        icon: Icons.location_city_rounded,
                                        label: 'Ciudad',
                                        activeColor: const Color(0xFFEA580C),
                                        activeBgColor: const Color(0xFFFFEDD5),
                                        isSelected:
                                            _selectedDestination.value ==
                                            'Ciudad',
                                        onTap: () {
                                          _selectedDestination.value = 'Ciudad';
                                          _showFeedbackSnackBar(
                                            'Destino seleccionado: Ciudad',
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _DestinationInkWellCard(
                                        icon: Icons.landscape_rounded,
                                        label: 'Montaña',
                                        activeColor: const Color(0xFF16A34A),
                                        activeBgColor: const Color(0xFFDCFCE7),
                                        isSelected:
                                            _selectedDestination.value ==
                                            'Montaña',
                                        onTap: () {
                                          _selectedDestination.value =
                                              'Montaña';
                                          _showFeedbackSnackBar(
                                            'Destino seleccionado: Montaña',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Transporte:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedTransport.value,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  items: _transportOptions.map((option) {
                                    IconData optionIcon;
                                    switch (option) {
                                      case 'Avión':
                                        optionIcon = Icons.flight_rounded;
                                        break;
                                      case 'Autobús':
                                        optionIcon =
                                            Icons.directions_bus_rounded;
                                        break;
                                      case 'Tren':
                                        optionIcon = Icons.train_rounded;
                                        break;
                                      default:
                                        optionIcon =
                                            Icons.directions_boat_rounded;
                                    }
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Row(
                                        children: [
                                          Icon(
                                            optionIcon,
                                            color: const Color(0xFFEA580C),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            option,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _selectedTransport.value = val;
                                      _showFeedbackSnackBar(
                                        'Transporte seleccionado: $val',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SectionCard(
                            icon: Icons.tune_rounded,
                            iconColor: AppColors.purpleAccent,
                            iconBgColor: AppColors.purpleLight,
                            title: 'Sección 4 · Extras y preferencias',
                            subtitle: 'Personaliza tu experiencia',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CheckboxListTileCard(
                                  icon: Icons.hotel_rounded,
                                  title: 'Hotel incluido (+ \$1200)',
                                  value: _hotelIncluded.value,
                                  onChanged: (val) {
                                    final newVal = val ?? false;
                                    _hotelIncluded.value = newVal;
                                    _showFeedbackSnackBar(
                                      newVal
                                          ? 'Hotel incluido activado'
                                          : 'Hotel incluido desactivado',
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _CheckboxListTileCard(
                                  icon: Icons.tour_rounded,
                                  title: 'Tour guiado (+ \$600)',
                                  value: _guidedTour.value,
                                  onChanged: (val) {
                                    final newVal = val ?? false;
                                    _guidedTour.value = newVal;
                                    _showFeedbackSnackBar(
                                      newVal
                                          ? 'Tour guiado activado'
                                          : 'Tour guiado desactivado',
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _CheckboxListTileCard(
                                  icon: Icons.health_and_safety_rounded,
                                  title: 'Seguro de viaje (+ \$400)',
                                  value: _travelInsurance.value,
                                  onChanged: (val) {
                                    final newVal = val ?? false;
                                    _travelInsurance.value = newVal;
                                    _showFeedbackSnackBar(
                                      newVal
                                          ? 'Seguro de viaje activado'
                                          : 'Seguro de viaje desactivado',
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: _notifications.value
                                        ? AppColors.purpleLight.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _notifications.value
                                          ? AppColors.purpleAccent.withValues(
                                              alpha: 0.3,
                                            )
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: SwitchListTile(
                                      title: const Text(
                                        'Recibir notificaciones',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _notifications.value
                                            ? 'Activadas'
                                            : 'Desactivadas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _notifications.value
                                              ? const Color(0xFF16A34A)
                                              : AppColors.textLight,
                                        ),
                                      ),
                                      value: _notifications.value,
                                      activeThumbColor: AppColors.purpleAccent,
                                      onChanged: (val) {
                                        _notifications.value = val;
                                        _showFeedbackSnackBar(
                                          val
                                              ? 'Notificaciones activadas'
                                              : 'Notificaciones desactivadas',
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.purpleLight.withValues(
                                      alpha: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Presupuesto:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.purpleAccent,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '\$${_budget.value.toInt()}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor:
                                              AppColors.purpleAccent,
                                          inactiveTrackColor: AppColors
                                              .purpleAccent
                                              .withValues(alpha: 0.2),
                                          thumbColor: AppColors.purpleAccent,
                                          overlayColor: AppColors.purpleAccent
                                              .withValues(alpha: 0.15),
                                        ),
                                        child: Slider(
                                          value: _budget.value,
                                          min: 500,
                                          max: 10000,
                                          divisions: 20,
                                          onChanged: (val) {
                                            _budget.value = val;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: _travelDate.value == null
                                            ? AppColors.purpleAccent.withValues(
                                                alpha: 0.5,
                                              )
                                            : AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.purpleLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_rounded,
                                            color: AppColors.purpleAccent,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Fecha del viaje',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textLight,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _travelDate.value == null
                                                    ? 'Toca para elegir fecha'
                                                    : '${_travelDate.value!.day.toString().padLeft(2, '0')}/${_travelDate.value!.month.toString().padLeft(2, '0')}/${_travelDate.value!.year}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      _travelDate.value == null
                                                      ? AppColors.textSecondary
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textLight,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.ticketGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Sección 5 · Confirmar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Revisa tus datos antes de despegar ✈️',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _showSummaryDialog,
                                        icon: const Icon(
                                          Icons.visibility_rounded,
                                          size: 18,
                                          color: AppColors.primaryDark,
                                        ),
                                        label: const Text(
                                          'Ver Resumen',
                                          style: TextStyle(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _submitBooking,
                                        icon: const Icon(
                                          Icons.flight_takeoff_rounded,
                                          size: 18,
                                          color: Color(0xFF5D3A00),
                                        ),
                                        label: const Text(
                                          'Confirmar',
                                          style: TextStyle(
                                            color: Color(0xFF5D3A00),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.accentYellow,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DestinationInkWellCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color activeColor;
  final Color activeBgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DestinationInkWellCard({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.activeBgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : AppColors.accent,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? activeColor : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckboxListTileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxListTileCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? AppColors.primaryLight.withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: CheckboxListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? AppColors.primaryLight : AppColors.borderLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: value ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
          value: value,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
