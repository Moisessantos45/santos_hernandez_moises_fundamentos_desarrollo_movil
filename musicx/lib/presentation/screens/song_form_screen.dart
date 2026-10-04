import 'package:flutter/material.dart';
import 'package:musicx/models/song_model.dart';
import 'package:musicx/presentation/widgets/custom_text_field.dart';
import 'package:musicx/services/supabase_service.dart';

class SongFormScreen extends StatefulWidget {
  final Song? song;

  const SongFormScreen({
    super.key,
    this.song,
  });

  @override
  State<SongFormScreen> createState() => _SongFormScreenState();
}

class _SongFormScreenState extends State<SongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  final _supabaseService = SupabaseService();
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  late final ValueNotifier<String> _imageUrlNotifier;

  bool get _isEditing => widget.song != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _descriptionController = TextEditingController(text: widget.song?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.song?.imageUrl ?? '');
    _imageUrlNotifier = ValueNotifier<String>(widget.song?.imageUrl ?? '');
    _imageUrlController.addListener(_onImageUrlChanged);
  }

  void _onImageUrlChanged() {
    _imageUrlNotifier.value = _imageUrlController.text.trim();
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_onImageUrlChanged);
    _titleController.dispose();
    _artistController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _isLoadingNotifier.dispose();
    _imageUrlNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoadingNotifier.value = true;

    try {
      if (_isEditing) {
        await _supabaseService.updateSong(
          id: widget.song!.id,
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
        );
      } else {
        await _supabaseService.createSong(
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Canción actualizada correctamente'
                : 'Canción agregada correctamente',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la canción: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Editar Canción' : 'Nueva Canción',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: _imageUrlNotifier,
                  builder: (context, previewUrl, _) {
                    return Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: previewUrl.isNotEmpty
                            ? Image.network(
                                previewUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 800,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 40,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'URL de imagen no válida',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 40,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Vista previa de la imagen',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Título de la canción',
                  hintText: 'Ej. Bohemian Rhapsody',
                  prefixIcon: Icons.music_note_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el título de la canción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _artistController,
                  labelText: 'Artista / Grupo',
                  hintText: 'Ej. Queen',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del artista';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _imageUrlController,
                  labelText: 'URL de la imagen',
                  hintText: 'https://ejemplo.com/caratula.jpg',
                  prefixIcon: Icons.link_rounded,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la URL de la imagen';
                    }
                    if (!Uri.tryParse(value.trim())!.isAbsolute) {
                      return 'Ingresa una URL válida (http:// o https://)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Descripción / Notas',
                  hintText: 'Ej. Lanzada en 1975 en el álbum A Night at the Opera',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoadingNotifier,
                  builder: (context, isLoading, _) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const RepaintBoundary(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditing ? 'Guardar Cambios' : 'Crear Canción',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
