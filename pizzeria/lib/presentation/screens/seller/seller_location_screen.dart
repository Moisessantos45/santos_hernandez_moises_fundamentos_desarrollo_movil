import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/models/restaurant_model.dart';
import 'package:pizzeria/presentation/providers/location_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';
import 'package:pizzeria/presentation/screens/map_location_picker_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerLocationScreen extends ConsumerStatefulWidget {
  const SellerLocationScreen({super.key});

  @override
  ConsumerState<SellerLocationScreen> createState() => _SellerLocationScreenState();
}

class _SellerLocationScreenState extends ConsumerState<SellerLocationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final ValueNotifier<String?> _nameErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _addressErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _latErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _lngErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFetchingGpsNotifier = ValueNotifier<bool>(false);

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    _nameErrorNotifier.dispose();
    _addressErrorNotifier.dispose();
    _latErrorNotifier.dispose();
    _lngErrorNotifier.dispose();
    _isLoadingNotifier.dispose();
    _isFetchingGpsNotifier.dispose();
    super.dispose();
  }

  void _populateFields(RestaurantModel rest) {
    if (_initialized) return;
    _nameController.text = rest.name;
    _descController.text = rest.description;
    _addressController.text = rest.address;
    _latController.text = rest.latitude.toString();
    _lngController.text = rest.longitude.toString();
    _phoneController.text = rest.phone;
    _imageUrlController.text = rest.imageUrl.isNotEmpty
        ? rest.imageUrl
        : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500';
    _initialized = true;
  }

  bool _validate() {
    _nameErrorNotifier.value = FormValidators.requiredField(
      _nameController.text,
      'Ingresa el nombre del establecimiento',
    );
    _addressErrorNotifier.value = FormValidators.requiredField(
      _addressController.text,
      'Ingresa la dirección completa',
    );
    _latErrorNotifier.value = FormValidators.coordinate(
      _latController.text,
      isLatitude: true,
    );
    _lngErrorNotifier.value = FormValidators.coordinate(
      _lngController.text,
      isLatitude: false,
    );

    return _nameErrorNotifier.value == null &&
        _addressErrorNotifier.value == null &&
        _latErrorNotifier.value == null &&
        _lngErrorNotifier.value == null;
  }

  Future<void> _fetchCurrentGps() async {
    _isFetchingGpsNotifier.value = true;
    try {
      final loc = await ref.read(userLocationProvider.future);
      _latController.text = loc.latitude.toStringAsFixed(6);
      _lngController.text = loc.longitude.toStringAsFixed(6);
      _latErrorNotifier.value = null;
      _lngErrorNotifier.value = null;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coordenadas GPS actualizadas con tu posición'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener GPS: $e')),
        );
      }
    } finally {
      _isFetchingGpsNotifier.value = false;
    }
  }

  Future<void> _pickLocationFromMap() async {
    final currentLat = double.tryParse(_latController.text.trim()) ?? 19.432608;
    final currentLng = double.tryParse(_lngController.text.trim()) ?? -99.133209;

    final result = await CustomNavigator.pushFade<MapLocationResult>(
      context,
      MapLocationPickerScreen(
        initialPosition: LatLng(currentLat, currentLng),
        title: 'Ubicación de tu Pizzería',
      ),
    );

    if (result != null) {
      _latController.text = result.position.latitude.toStringAsFixed(6);
      _lngController.text = result.position.longitude.toStringAsFixed(6);
      _latErrorNotifier.value = null;
      _lngErrorNotifier.value = null;
      setState(() {});
    }
  }

  Future<void> _handleSave(RestaurantModel current) async {
    if (!_validate()) return;

    _isLoadingNotifier.value = true;
    try {
      final updated = current.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()) ?? current.latitude,
        longitude: double.tryParse(_lngController.text.trim()) ?? current.longitude,
        phone: _phoneController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      await ref.read(sellerRestaurantProvider.notifier).updateRestaurant(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Información del local guardada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(sellerRestaurantProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'Mi Pizzería / Ubicación',
        showBackButton: false,
      ),
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant != null) {
            _populateFields(restaurant);
          }

          final currentLat = double.tryParse(_latController.text.trim()) ?? 19.432608;
          final currentLng = double.tryParse(_lngController.text.trim()) ?? -99.133209;
          final currentPos = LatLng(currentLat, currentLng);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final isTablet = constraints.maxWidth >= 600;
              final horizontalPadding = isTablet || isLandscape ? 40.0 : 20.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Esta información y coordenadas se mostrarán a los clientes en el mapa para que encuentren tu pizzería.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<String?>(
                      valueListenable: _nameErrorNotifier,
                      builder: (context, err, _) {
                        return CustomTextField(
                          controller: _nameController,
                          label: 'Nombre de la Pizzería',
                          hintText: 'Ej. Pizzería Bella Napoli',
                          prefixIcon: Icons.storefront_outlined,
                          errorText: err,
                          onChanged: (_) => _nameErrorNotifier.value = null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descController,
                      label: 'Descripción / Especialidad',
                      hintText: 'Pizzas a la leña, masa madre e ingredientes importados.',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<String?>(
                      valueListenable: _addressErrorNotifier,
                      builder: (context, err, _) {
                        return CustomTextField(
                          controller: _addressController,
                          label: 'Dirección Física del Local',
                          hintText: 'Av. Juárez 45, Centro Histórico',
                          prefixIcon: Icons.location_on_outlined,
                          errorText: err,
                          onChanged: (_) => _addressErrorNotifier.value = null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<String?>(
                            valueListenable: _latErrorNotifier,
                            builder: (context, err, _) {
                              return CustomTextField(
                                controller: _latController,
                                label: 'Latitud',
                                hintText: '19.432608',
                                prefixIcon: Icons.my_location,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                errorText: err,
                                onChanged: (_) {
                                  _latErrorNotifier.value = null;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ValueListenableBuilder<String?>(
                            valueListenable: _lngErrorNotifier,
                            builder: (context, err, _) {
                              return CustomTextField(
                                controller: _lngController,
                                label: 'Longitud',
                                hintText: '-99.133209',
                                prefixIcon: Icons.my_location,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                errorText: err,
                                onChanged: (_) {
                                  _lngErrorNotifier.value = null;
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          FlutterMap(
                            key: ValueKey('${currentPos.latitude}_${currentPos.longitude}'),
                            options: MapOptions(
                              initialCenter: currentPos,
                              initialZoom: 14.5,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.pizzeria.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: currentPos,
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.local_pizza,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _pickLocationFromMap,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.touch_app, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Toca para expandir mapa',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickLocationFromMap,
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Elegir en el Mapa'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isFetchingGpsNotifier,
                            builder: (context, isFetching, _) {
                              return OutlinedButton.icon(
                                onPressed: isFetching ? null : _fetchCurrentGps,
                                icon: isFetching
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.gps_fixed, size: 18),
                                label: const Text('Mi GPS Actual'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Teléfono de Contacto',
                      hintText: '555-123-4567',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _imageUrlController,
                      label: 'Foto de Fachada / Logo (URL)',
                      hintText: 'https://images.unsplash.com/...',
                      prefixIcon: Icons.image_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 32),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isLoadingNotifier,
                      builder: (context, isLoading, _) {
                        return CustomButton(
                          text: 'Guardar Configuración del Local',
                          isLoading: isLoading,
                          onPressed: () {
                            if (restaurant != null) {
                              _handleSave(restaurant);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: DashedOvenLoader()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
