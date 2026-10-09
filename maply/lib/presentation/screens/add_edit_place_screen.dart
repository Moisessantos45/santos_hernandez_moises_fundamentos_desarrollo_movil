import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maply/models/place.dart';
import 'package:maply/presentation/widgets/widgets.dart';
import 'package:maply/services/location_service.dart';
import 'package:maply/services/supabase_service.dart';

class AddEditPlaceScreen extends StatefulWidget {
  final Place? place;
  final LatLng? initialLocation;

  const AddEditPlaceScreen({
    super.key,
    this.place,
    this.initialLocation,
  });

  @override
  State<AddEditPlaceScreen> createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final List<String> _categories = [
    'Comida',
    'Estudio',
    'Diversión',
    'Hogar',
    'Deporte',
    'Café',
    'Otro',
  ];

  late final ValueNotifier<String> _selectedCategory;
  late final ValueNotifier<double> _latitude;
  late final ValueNotifier<double> _longitude;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoadingGps = ValueNotifier<bool>(false);
  final ValueNotifier<String> _imageUrlValue = ValueNotifier<String>('');

  final List<String> _presetImages = [
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500',
    'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=500',
    'https://images.unsplash.com/photo-1498243691581-b145c3f54a5a?w=500',
  ];

  @override
  void initState() {
    super.initState();
    final place = widget.place;
    if (place != null) {
      _titleController.text = place.title;
      _descriptionController.text = place.description;
      _imageUrlController.text = place.imageUrl;
      _imageUrlValue.value = place.imageUrl;
      _selectedCategory = ValueNotifier<String>(place.category);
      _latitude = ValueNotifier<double>(place.latitude);
      _longitude = ValueNotifier<double>(place.longitude);
    } else {
      _selectedCategory = ValueNotifier<String>('Comida');
      _latitude = ValueNotifier<double>(widget.initialLocation?.latitude ?? 19.4326);
      _longitude = ValueNotifier<double>(widget.initialLocation?.longitude ?? -99.1332);
      if (widget.initialLocation == null) {
        _fetchInitialGps();
      }
    }
  }

  Future<void> _fetchInitialGps() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null && widget.place == null) {
      _latitude.value = pos.latitude;
      _longitude.value = pos.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _selectedCategory.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _isLoading.dispose();
    _isLoadingGps.dispose();
    _imageUrlValue.dispose();
    super.dispose();
  }

  Future<void> _pickLocationOnMap() async {
    final selected = await MapPickerDialog.show(
      context,
      initialPoint: LatLng(_latitude.value, _longitude.value),
    );

    if (selected != null) {
      _latitude.value = selected.latitude;
      _longitude.value = selected.longitude;
    }
  }

  Future<void> _useCurrentGps() async {
    _isLoadingGps.value = true;
    final pos = await LocationService.getCurrentLocation();
    _isLoadingGps.value = false;

    if (pos != null) {
      _latitude.value = pos.latitude;
      _longitude.value = pos.longitude;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación GPS obtenida con éxito'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación GPS.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      if (widget.place != null) {
        final updatedPlace = widget.place!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory.value,
          imageUrl: _imageUrlController.text.trim(),
          latitude: _latitude.value,
          longitude: _longitude.value,
        );

        final result = await SupabaseService.updatePlace(updatedPlace);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lugar actualizado con éxito'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(result);
        }
      } else {
        final newPlace = Place(
          id: '',
          userId: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory.value,
          imageUrl: _imageUrlController.text.trim(),
          latitude: _latitude.value,
          longitude: _longitude.value,
          createdAt: DateTime.now(),
        );

        final result = await SupabaseService.addPlace(newPlace);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lugar guardado con éxito'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.of(context).pop(result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.place != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Lugar' : 'Nuevo Lugar Favorito',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Nombre del Lugar',
                hint: 'Ej: Café Central, Gimnasio, Mi Casa',
                prefixIcon: Icons.place_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre para el lugar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: _selectedCategory,
                builder: (context, currentCat, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = currentCat == category;
                      return CategoryBadge(
                        category: category,
                        isSelected: isSelected,
                        onTap: () {
                          _selectedCategory.value = category;
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              CustomTextField(
                controller: _descriptionController,
                label: 'Descripción o Notas',
                hint: '¿Por qué te gusta este lugar?',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 18),
              CustomTextField(
                controller: _imageUrlController,
                label: 'URL de la Foto',
                hint: 'https://ejemplo.com/foto.jpg',
                keyboardType: TextInputType.url,
                prefixIcon: Icons.image_outlined,
                onChanged: (val) {
                  _imageUrlValue.value = val;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'O selecciona una imagen de ejemplo:',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: _imageUrlValue,
                builder: (context, currentUrl, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _presetImages.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final url = _presetImages[index];
                            final isSelected = currentUrl == url;
                            return InkWell(
                              onTap: () {
                                _imageUrlController.text = url;
                                _imageUrlValue.value = url;
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFE2E8F0),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (currentUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            color: const Color(0xFFF1F5F9),
                            child: Image.network(
                              currentUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text(
                                  'URL de imagen no válida',
                                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Ubicación Geográfica',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: _latitude,
                      builder: (context, latVal, _) {
                        return ValueListenableBuilder<double>(
                          valueListenable: _longitude,
                          builder: (context, lngVal, _) {
                            return Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Lat: ${latVal.toStringAsFixed(6)}, Lng: ${lngVal.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickLocationOnMap,
                            icon: const Icon(Icons.map_rounded, size: 16),
                            label: const Text('Elegir en Mapa'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isLoadingGps,
                            builder: (context, loadingGps, _) {
                              return OutlinedButton.icon(
                                onPressed: loadingGps ? null : _useCurrentGps,
                                icon: loadingGps
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.my_location_rounded, size: 16),
                                label: const Text('Mi GPS'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF10B981),
                                  side: const BorderSide(color: Color(0xFF10B981)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, loadingVal, _) {
                  return CustomButton(
                    text: isEditing ? 'Guardar Cambios' : 'Agregar Lugar',
                    isLoading: loadingVal,
                    onPressed: _handleSave,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
