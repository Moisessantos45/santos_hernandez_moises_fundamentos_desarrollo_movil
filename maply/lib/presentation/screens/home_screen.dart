import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maply/models/place.dart';
import 'package:maply/presentation/screens/add_edit_place_screen.dart';
import 'package:maply/presentation/screens/map_screen.dart';
import 'package:maply/presentation/screens/places_list_screen.dart';
import 'package:maply/presentation/screens/profile_screen.dart';
import 'package:maply/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<List<Place>> _places = ValueNotifier<List<Place>>([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<LatLng?> _mapFocusLocation = ValueNotifier<LatLng?>(null);

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _places.dispose();
    _isLoading.dispose();
    _mapFocusLocation.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    _isLoading.value = true;
    try {
      final fetchedPlaces = await SupabaseService.getPlaces();
      _places.value = fetchedPlaces;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar lugares: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void _onShowOnMap(LatLng coordinates) {
    _mapFocusLocation.value = coordinates;
    _currentIndex.value = 0;
  }

  Future<void> _navigateToAddPlace() async {
    final newPlace = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => const AddEditPlaceScreen(),
      ),
    );

    if (newPlace != null) {
      _loadPlaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.map_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Maply',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<List<Place>>(
              valueListenable: _places,
              builder: (context, placesList, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${placesList.length}',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF0F172A),
            ),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(places: _places.value),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, loadingVal, _) {
          return ValueListenableBuilder<List<Place>>(
            valueListenable: _places,
            builder: (context, placesList, _) {
              if (loadingVal && placesList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                );
              }

              return ValueListenableBuilder<int>(
                valueListenable: _currentIndex,
                builder: (context, currentTab, _) {
                  return ValueListenableBuilder<LatLng?>(
                    valueListenable: _mapFocusLocation,
                    builder: (context, focusLocation, _) {
                      return IndexedStack(
                        index: currentTab,
                        children: [
                          MapScreen(
                            places: placesList,
                            onRefresh: _loadPlaces,
                            centerOnLocation: focusLocation,
                          ),
                          PlacesListScreen(
                            places: placesList,
                            onRefresh: _loadPlaces,
                            onShowOnMap: _onShowOnMap,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_place_fab',
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _navigateToAddPlace,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Nuevo Lugar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (context, tabIndex, _) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: (index) {
                _currentIndex.value = index;
              },
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF2563EB),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map_rounded),
                  label: 'Mapa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.format_list_bulleted_rounded),
                  activeIcon: Icon(Icons.list_alt_rounded),
                  label: 'Mis Lugares',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
