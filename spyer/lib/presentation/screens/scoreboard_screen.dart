import 'package:flutter/material.dart';
import '../../models/nfl_scoreboard_model.dart';
import '../../services/nfl_api_service.dart';
import '../widgets/game_card.dart';

enum GameFilter { all, live, scheduled, completed }

class ScoreboardScreen extends StatefulWidget {
  final NflApiService? apiService;

  const ScoreboardScreen({super.key, this.apiService});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  late final NflApiService _apiService;
  final TextEditingController _searchController = TextEditingController();

  NflScoreboardResponse? _scoreboardData;
  bool _isLoading = true;
  String? _errorMessage;

  GameFilter _currentFilter = GameFilter.all;
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 5; // Options: 5, 10, 0 (0 = all)

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? NflApiService();
    _fetchScoreboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchScoreboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getScoreboard();
      if (mounted) {
        setState(() {
          _scoreboardData = data;
          _isLoading = false;
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<NflEvent> get _filteredEvents {
    if (_scoreboardData == null) return [];
    var list = _scoreboardData!.events;

    switch (_currentFilter) {
      case GameFilter.live:
        list = list.where((e) => e.status.isLive).toList();
        break;
      case GameFilter.scheduled:
        list = list.where((e) => e.status.isScheduled).toList();
        break;
      case GameFilter.completed:
        list = list.where((e) => e.status.isFinal).toList();
        break;
      case GameFilter.all:
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((e) {
        final away = e.awayCompetitor?.team;
        final home = e.homeCompetitor?.team;
        return e.name.toLowerCase().contains(query) ||
            e.shortName.toLowerCase().contains(query) ||
            (away != null &&
                (away.displayName.toLowerCase().contains(query) ||
                    away.abbreviation.toLowerCase().contains(query) ||
                    away.name.toLowerCase().contains(query))) ||
            (home != null &&
                (home.displayName.toLowerCase().contains(query) ||
                    home.abbreviation.toLowerCase().contains(query) ||
                    home.name.toLowerCase().contains(query)));
      }).toList();
    }

    return list;
  }

  List<NflEvent> get _paginatedEvents {
    final filtered = _filteredEvents;
    if (_itemsPerPage <= 0) return filtered;

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    final filtered = _filteredEvents;
    if (_itemsPerPage <= 0 || filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_football,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NFL Scoreboard',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_scoreboardData != null)
                  Text(
                    '${_scoreboardData!.leagueName ?? "NFL"} • Sem ${_scoreboardData!.weekNumber ?? "4"}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            tooltip: 'Actualizar partidos',
            onPressed: _isLoading ? null : _fetchScoreboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchScoreboard,
        color: const Color(0xFF2563EB),
        child: Column(
          children: [
            // Search and Filter Bar
            _buildSearchAndFilters(),

            // Content Area
            Expanded(child: _buildBody()),

            // Pagination Controls
            if (!_isLoading &&
                _errorMessage == null &&
                _filteredEvents.isNotEmpty)
              _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 1;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar equipo (ej. Chiefs, 49ers, CLE)...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade500,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _currentPage = 1;
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', GameFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('🔴 En Vivo', GameFilter.live),
                const SizedBox(width: 8),
                _buildFilterChip('⏰ Próximos', GameFilter.scheduled),
                const SizedBox(width: 8),
                _buildFilterChip('✅ Finalizados', GameFilter.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, GameFilter filter) {
    final isSelected = _currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentFilter = filter;
            _currentPage = 1;
          });
        }
      },
      selectedColor: const Color(0xFF0F172A),
      backgroundColor: const Color(0xFFF8FAFC),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF2563EB),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando marcadores de la NFL...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar la información',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchScoreboard,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final events = _paginatedEvents;

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_football_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                'No se encontraron partidos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No hay resultados para "$_searchQuery"'
                    : 'No hay partidos con el filtro seleccionado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return GameCard(event: events[index]);
      },
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = _totalPages;
    final totalCount = _filteredEvents.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page selector
          Row(
            children: [
              Text(
                'Mostrar: ',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              DropdownButton<int>(
                value: _itemsPerPage,
                isDense: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 0, child: Text('Todos')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _itemsPerPage = val;
                      _currentPage = 1;
                    });
                  }
                },
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($totalCount total)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),

          // Prev / Next Page Buttons
          if (_itemsPerPage > 0)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 22,
                  color: const Color(0xFF0F172A),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Página $_currentPage de $totalPages',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 22,
                  color: const Color(0xFF0F172A),
                  onPressed: _currentPage < totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
