import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:pizzeria/models/restaurant_model.dart';
import 'package:pizzeria/presentation/providers/location_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final ValueNotifier<RestaurantModel?> _selectedRestaurantNotifier =
      ValueNotifier<RestaurantModel?>(null);

  @override
  void dispose() {
    _mapController.dispose();
    _selectedRestaurantNotifier.dispose();
    super.dispose();
  }

  void _showRestaurantModal(BuildContext context, RestaurantModel restaurant) {
    _selectedRestaurantNotifier.value = restaurant;
    _mapController.move(
      LatLng(restaurant.latitude, restaurant.longitude),
      15.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'Pizzerías Cercanas',
        showBackButton: false,
      ),
      body: locationAsync.when(
        data: (userPos) {
          return restaurantsAsync.when(
            data: (restaurants) {
              final List<Marker> markers = [
                Marker(
                  point: userPos,
                  width: 60,
                  height: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Tú',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ...restaurants.map((rest) {
                  return Marker(
                    point: LatLng(rest.latitude, rest.longitude),
                    width: 80,
                    height: 70,
                    child: GestureDetector(
                      onTap: () => _showRestaurantModal(context, rest),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_pizza,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              rest.name.length > 10 ? '${rest.name.substring(0, 8)}..' : rest.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ];

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: userPos,
                      initialZoom: 13.5,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.pizzeria.app',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: AppColors.primary,
                      onPressed: () {
                        ref.read(userLocationProvider.notifier).refreshLocation();
                        _mapController.move(userPos, 14.5);
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: ValueListenableBuilder<RestaurantModel?>(
                      valueListenable: _selectedRestaurantNotifier,
                      builder: (context, selectedRest, _) {
                        if (selectedRest == null) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.touch_app_outlined, color: AppColors.primary),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Toca cualquier pizzería en el mapa para ver su información y ubicación.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      selectedRest.imageUrl.isNotEmpty
                                          ? selectedRest.imageUrl
                                          : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
                                      width: 68,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => Container(
                                        width: 68,
                                        height: 68,
                                        color: AppColors.inputBackground,
                                        child: const Icon(Icons.storefront, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedRest.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedRest.address,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (selectedRest.phone.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 12, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Text(
                                                selectedRest.phone,
                                                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: AppColors.textLight),
                                    onPressed: () => _selectedRestaurantNotifier.value = null,
                                  ),
                                ],
                              ),
                              if (selectedRest.description.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  selectedRest.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: DashedOvenLoader()),
            error: (err, _) => Center(child: Text('Error al cargar mapa: $err')),
          );
        },
        loading: () => const Center(child: DashedOvenLoader()),
        error: (err, _) => Center(child: Text('Error al obtener ubicación: $err')),
      ),
    );
  }
}
