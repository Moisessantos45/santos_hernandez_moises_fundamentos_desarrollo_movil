import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maply/models/place.dart';
import 'package:maply/presentation/screens/add_edit_place_screen.dart';
import 'package:maply/presentation/screens/place_detail_screen.dart';
import 'package:maply/presentation/widgets/widgets.dart';
import 'package:maply/services/location_service.dart';
import 'package:maply/services/supabase_service.dart';

class MapScreen extends StatefulWidget {
  final List<Place> places;
  final VoidCallback onRefresh;
  final LatLng? centerOnLocation;

  const MapScreen({
    super.key,
    required this.places,
    required this.onRefresh,
    this.centerOnLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ValueNotifier<LatLng?> _userLocation = ValueNotifier<LatLng?>(null);
  final ValueNotifier<String?> _selectedCategory = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);

  final List<String> _categories = [
    'Comida',
    'Estudio',
    'Diversión',
    'Hogar',
    'Deporte',
    'Café',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    if (widget.centerOnLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.centerOnLocation!, 15.0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.centerOnLocation != null &&
        widget.centerOnLocation != oldWidget.centerOnLocation) {
      _mapController.move(widget.centerOnLocation!, 15.0);
    }
  }

  @override
  void dispose() {
    _userLocation.dispose();
    _selectedCategory.dispose();
    _isLoadingLocation.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    _isLoadingLocation.value = true;
    final pos = await LocationService.getCurrentLocation();
    _userLocation.value = pos;
    _isLoadingLocation.value = false;
  }

  void _centerOnUser() {
    if (_userLocation.value != null) {
      _mapController.move(_userLocation.value!, 15.0);
    } else {
      _getUserLocation().then((_) {
        if (_userLocation.value != null) {
          _mapController.move(_userLocation.value!, 15.0);
        }
      });
    }
  }

  void _showPlaceDetailsBottomSheet(Place place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              PlaceCard(
                place: place,
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailScreen(place: place),
                    ),
                  ).then((_) => widget.onRefresh());
                },
                onEdit: () {
                  Navigator.of(bottomSheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditPlaceScreen(place: place),
                    ),
                  ).then((_) => widget.onRefresh());
                },
                onDelete: () {
                  Navigator.of(bottomSheetContext).pop();
                  DeleteDialog.show(
                    context,
                    title: 'Eliminar Lugar',
                    content: '¿Estás seguro de eliminar "${place.title}"?',
                    onConfirm: () async {
                      try {
                        await SupabaseService.deletePlace(place.id);
                        widget.onRefresh();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
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
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LatLng?>(
      valueListenable: _userLocation,
      builder: (context, userLoc, _) {
        final defaultCenter = widget.centerOnLocation ??
            userLoc ??
            (widget.places.isNotEmpty
                ? widget.places.first.coordinates
                : const LatLng(19.4326, -99.1332));

        return ValueListenableBuilder<String?>(
          valueListenable: _selectedCategory,
          builder: (context, currentCat, _) {
            final filtered = currentCat == null
                ? widget.places
                : widget.places
                    .where((p) => p.category.toLowerCase() == currentCat.toLowerCase())
                    .toList();

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: defaultCenter,
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {},
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.maply',
                    ),
                    MarkerLayer(
                      markers: [
                        if (userLoc != null)
                          Marker(
                            point: userLoc,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ...filtered.map((place) {
                          final color = CategoryBadge.getCategoryColor(place.category);
                          final icon = CategoryBadge.getCategoryIcon(place.category);

                          return Marker(
                            point: place.coordinates,
                            width: 44,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () => _showPlaceDetailsBottomSheet(place),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: color,
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
                                    child: Icon(
                                      icon,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: CategoryFilterBar(
                    categories: _categories,
                    selectedCategory: currentCat,
                    onCategorySelected: (cat) {
                      _selectedCategory.value = cat;
                    },
                  ),
                ),
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'refresh_map_btn',
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 3,
                        onPressed: widget.onRefresh,
                        child: const Icon(Icons.refresh_rounded),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoadingLocation,
                        builder: (context, loadingLoc, _) {
                          return FloatingActionButton(
                            heroTag: 'my_location_btn',
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            onPressed: loadingLoc ? null : _centerOnUser,
                            child: loadingLoc
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
