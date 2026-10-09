import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maply/models/place.dart';
import 'package:maply/presentation/screens/add_edit_place_screen.dart';
import 'package:maply/presentation/widgets/widgets.dart';
import 'package:maply/services/supabase_service.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late final ValueNotifier<Place> _place;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _place = ValueNotifier<Place>(widget.place);
  }

  @override
  void dispose() {
    _place.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final confirmed = await DeleteDialog.show(
      context,
      title: 'Eliminar Lugar',
      content: '¿Estás seguro de que deseas eliminar "${_place.value.title}"? Esta acción no se puede deshacer.',
      onConfirm: () async {
        try {
          await SupabaseService.deletePlace(_place.value.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lugar eliminado correctamente'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
            Navigator.of(context).pop(true);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar: $e'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        }
      },
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleEdit() async {
    final updatedPlace = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => AddEditPlaceScreen(place: _place.value),
      ),
    );

    if (updatedPlace != null) {
      _place.value = updatedPlace;
      _mapController.move(updatedPlace.coordinates, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Place>(
      valueListenable: _place,
      builder: (context, currentPlace, _) {
        final categoryColor = CategoryBadge.getCategoryColor(currentPlace.category);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              currentPlace.title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _handleEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                onPressed: _handleDelete,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 220,
                  color: const Color(0xFFE2E8F0),
                  child: currentPlace.imageUrl.isNotEmpty
                      ? Image.network(
                          currentPlace.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              CategoryBadge.getCategoryIcon(currentPlace.category),
                              size: 64,
                              color: categoryColor,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            CategoryBadge.getCategoryIcon(currentPlace.category),
                            size: 64,
                            color: categoryColor,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryBadge(category: currentPlace.category),
                          const Spacer(),
                          Text(
                            'Guardado el ${currentPlace.createdAt.day}/${currentPlace.createdAt.month}/${currentPlace.createdAt.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currentPlace.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (currentPlace.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          currentPlace.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Ubicación en el Mapa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: currentPlace.coordinates,
                            initialZoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.maply',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: currentPlace.coordinates,
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: categoryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: categoryColor.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      CategoryBadge.getCategoryIcon(currentPlace.category),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.pin_drop_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lat: ${currentPlace.latitude.toStringAsFixed(5)}, Lng: ${currentPlace.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
