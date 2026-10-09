import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maply/models/place.dart';
import 'package:maply/presentation/screens/add_edit_place_screen.dart';
import 'package:maply/presentation/screens/place_detail_screen.dart';
import 'package:maply/presentation/widgets/widgets.dart';
import 'package:maply/services/supabase_service.dart';

class PlacesListScreen extends StatefulWidget {
  final List<Place> places;
  final Future<void> Function() onRefresh;
  final Function(LatLng coordinates)? onShowOnMap;

  const PlacesListScreen({
    super.key,
    required this.places,
    required this.onRefresh,
    this.onShowOnMap,
  });

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  final _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String?> _selectedCategory = ValueNotifier<String?>(null);

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
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  Future<void> _deletePlace(Place place) async {
    await DeleteDialog.show(
      context,
      title: 'Eliminar Lugar',
      content: '¿Estás seguro de que deseas eliminar "${place.title}"?',
      onConfirm: () async {
        try {
          await SupabaseService.deletePlace(place.id);
          await widget.onRefresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lugar eliminado correctamente'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, queryVal, _) {
              return TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchQuery.value = value;
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o descripción...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                  suffixIcon: queryVal.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery.value = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 12),
          child: ValueListenableBuilder<String?>(
            valueListenable: _selectedCategory,
            builder: (context, currentCategory, _) {
              return CategoryFilterBar(
                categories: _categories,
                selectedCategory: currentCategory,
                onCategorySelected: (category) {
                  _selectedCategory.value = category;
                },
              );
            },
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: _searchQuery,
          builder: (context, queryVal, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: _selectedCategory,
              builder: (context, currentCategory, _) {
                final filtered = widget.places.where((place) {
                  final matchesSearch = queryVal.isEmpty ||
                      place.title.toLowerCase().contains(queryVal.toLowerCase()) ||
                      place.description.toLowerCase().contains(queryVal.toLowerCase());

                  final matchesCategory = currentCategory == null ||
                      place.category.toLowerCase() == currentCategory.toLowerCase();

                  return matchesSearch && matchesCategory;
                }).toList();

                return Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lugares (${filtered.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                            if (currentCategory != null || queryVal.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _selectedCategory.value = null;
                                  _searchQuery.value = '';
                                  _searchController.clear();
                                },
                                child: const Text(
                                  'Limpiar filtros',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: widget.onRefresh,
                          color: const Color(0xFF2563EB),
                          child: filtered.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.place_outlined,
                                              size: 48,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            widget.places.isEmpty
                                                ? 'Aún no tienes lugares guardados'
                                                : 'No se encontraron resultados',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF334155),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            widget.places.isEmpty
                                                ? 'Toca el botón + para agregar tu primer lugar favorito.'
                                                : 'Prueba con otra búsqueda o categoría.',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final place = filtered[index];
                                    return PlaceCard(
                                      place: place,
                                      onTap: () async {
                                        final updated = await Navigator.of(context).push<bool>(
                                          MaterialPageRoute(
                                            builder: (_) => PlaceDetailScreen(place: place),
                                          ),
                                        );
                                        if (updated == true) {
                                          widget.onRefresh();
                                        }
                                      },
                                      onEdit: () async {
                                        final updated = await Navigator.of(context).push<Place>(
                                          MaterialPageRoute(
                                            builder: (_) => AddEditPlaceScreen(place: place),
                                          ),
                                        );
                                        if (updated != null) {
                                          widget.onRefresh();
                                        }
                                      },
                                      onDelete: () => _deletePlace(place),
                                      onShowOnMap: widget.onShowOnMap != null
                                          ? () => widget.onShowOnMap!(place.coordinates)
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
