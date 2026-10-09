import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maply/services/location_service.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng initialPoint;

  const MapPickerDialog({
    super.key,
    required this.initialPoint,
  });

  static Future<LatLng?> show(
    BuildContext context, {
    required LatLng initialPoint,
  }) {
    return showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapPickerDialog(initialPoint: initialPoint),
    );
  }

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late final ValueNotifier<LatLng> _selectedPoint;
  final ValueNotifier<bool> _isLoadingGps = ValueNotifier<bool>(false);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedPoint = ValueNotifier<LatLng>(widget.initialPoint);
  }

  @override
  void dispose() {
    _selectedPoint.dispose();
    _isLoadingGps.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    _isLoadingGps.value = true;
    final pos = await LocationService.getCurrentLocation();
    _isLoadingGps.value = false;

    if (pos != null) {
      _selectedPoint.value = pos;
      _mapController.move(pos, 15.0);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación actual.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seleccionar Ubicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ValueListenableBuilder<LatLng>(
                  valueListenable: _selectedPoint,
                  builder: (context, currentPoint, _) {
                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: currentPoint,
                        initialZoom: 14.0,
                        onTap: (tapPosition, point) {
                          _selectedPoint.value = point;
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.maply',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: currentPoint,
                              width: 48,
                              height: 48,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFDC2626),
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isLoadingGps,
                    builder: (context, loadingGps, _) {
                      return FloatingActionButton.small(
                        heroTag: 'gps_picker_btn',
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        onPressed: loadingGps ? null : _goToCurrentLocation,
                        child: loadingGps
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location_rounded),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: ValueListenableBuilder<LatLng>(
                    valueListenable: _selectedPoint,
                    builder: (context, currentPoint, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Toca el mapa para fijar el punto: Lat ${currentPoint.latitude.toStringAsFixed(5)}, Lng ${currentPoint.longitude.toStringAsFixed(5)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selectedPoint.value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmar Ubicación',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
