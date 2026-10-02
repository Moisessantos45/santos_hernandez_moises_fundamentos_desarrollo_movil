import 'package:flutter/material.dart';
import '../../models/nfl_scoreboard_model.dart';

class GameCard extends StatelessWidget {
  final NflEvent event;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.event,
    this.onTap,
  });

  Color _parseHexColor(String? hexString, Color defaultColor) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    try {
      final cleanHex = hexString.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
    } catch (_) {}
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final awayComp = event.awayCompetitor;
    final homeComp = event.homeCompetitor;
    final status = event.status;
    final venue = event.primaryCompetition?.venue;
    final broadcasts = event.primaryCompetition?.broadcasts ?? [];

    final isLive = status.isLive;
    final isFinal = status.isFinal;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status and Broadcast
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(status),
                  if (broadcasts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tv, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            broadcasts.first,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (status.shortDetail.isNotEmpty && !isLive && !isFinal)
                    Text(
                      status.shortDetail,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Matchup Details (Away Team vs Home Team)
              if (awayComp != null)
                _buildTeamRow(
                  competitor: awayComp,
                  isWinner: isFinal && (int.tryParse(awayComp.score) ?? 0) > (int.tryParse(homeComp?.score ?? '0') ?? 0),
                  isLiveOrFinal: isLive || isFinal,
                  label: 'VISITANTE',
                ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),

              if (homeComp != null)
                _buildTeamRow(
                  competitor: homeComp,
                  isWinner: isFinal && (int.tryParse(homeComp.score) ?? 0) > (int.tryParse(awayComp?.score ?? '0') ?? 0),
                  isLiveOrFinal: isLive || isFinal,
                  label: 'LOCAL',
                ),

              // Footer: Stadium & Weather
              if (venue != null || event.weatherDisplay != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (venue != null && venue.fullName.isNotEmpty) ...[
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.location.isNotEmpty
                                ? '${venue.fullName} • ${venue.location}'
                                : venue.fullName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (event.weatherDisplay != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny_outlined, size: 13, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '${event.temperature != null ? '${event.temperature}° ' : ''}${event.weatherDisplay}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(NflStatus status) {
    if (status.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'EN VIVO • ${status.displayClock.isNotEmpty ? status.displayClock : ''} Q${status.period}',
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (status.isFinal) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.description.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    // Scheduled
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 13, color: Color(0xFF2563EB)),
          const SizedBox(width: 5),
          Text(
            status.detail.isNotEmpty ? status.detail : 'Programado',
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required NflCompetitor competitor,
    required bool isWinner,
    required bool isLiveOrFinal,
    required String label,
  }) {
    final team = competitor.team;
    final primaryColor = _parseHexColor(team.colorHex, const Color(0xFF1E293B));

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 38,
            height: 38,
            color: const Color(0xFFF8FAFC),
            child: team.logo != null && team.logo!.isNotEmpty
                ? Image.network(
                    team.logo!,
                    cacheWidth: 120,
                    cacheHeight: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildTeamAvatar(team, primaryColor),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: RepaintBoundary(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : _buildTeamAvatar(team, primaryColor),
          ),
        ),

        const SizedBox(width: 12),

        // Team Name & Record
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      team.displayName.isNotEmpty ? team.displayName : team.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600,
                        color: isWinner ? const Color(0xFF0F172A) : const Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (team.abbreviation.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      team.abbreviation,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                competitor.recordSummary != null && competitor.recordSummary!.isNotEmpty
                    ? 'Récord: ${competitor.recordSummary}'
                    : label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        if (isLiveOrFinal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isWinner ? const Color(0xFFBBF7D0) : Colors.transparent,
              ),
            ),
            child: Text(
              competitor.score,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isWinner ? const Color(0xFF166534) : const Color(0xFF1E293B),
              ),
            ),
          )
        else
          Text(
            '-',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
      ],
    );
  }

  Widget _buildTeamAvatar(NflTeam team, Color color) {
    final initials = team.abbreviation.isNotEmpty
        ? team.abbreviation.substring(0, team.abbreviation.length.clamp(1, 3))
        : (team.name.isNotEmpty ? team.name.substring(0, 1) : '?');

    return Container(
      alignment: Alignment.center,
      color: color.withValues(alpha: 0.1),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
