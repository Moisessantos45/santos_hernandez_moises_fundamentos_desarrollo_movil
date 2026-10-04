import 'package:flutter/material.dart';
import 'package:musicx/models/song_model.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SongCard({
    super.key,
    required this.song,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: song.imageUrl.isNotEmpty
                  ? Image.network(
                      song.imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: RepaintBoundary(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFEEF2FF),
                          child: const Center(
                            child: Icon(
                              Icons.music_note_rounded,
                              size: 48,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFFEEF2FF),
                      child: const Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 48,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (song.artist.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: 15,
                                    color: Color(0xFF6366F1),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      song.artist,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                  if (song.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      song.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
