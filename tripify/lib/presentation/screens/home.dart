import 'package:flutter/material.dart';
import 'package:tripify/core/navigation/custom_navigator.dart';
import 'package:tripify/core/theme/app_colors.dart';
import 'package:tripify/data/mock/mock_trips.dart';
import 'package:tripify/domain/models/trip.dart';
import 'package:tripify/presentation/widgets/widgets.dart';
import 'trip_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> _navBarIndex = ValueNotifier<int>(2);
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<List<Trip>> _trips = ValueNotifier<List<Trip>>(
    List.from(mockTrips),
  );

  final ValueNotifier<String> _filterCategory = ValueNotifier<String>('All');
  final ValueNotifier<String> _filterTransport = ValueNotifier<String>('All');
  final ValueNotifier<String> _filterLocation = ValueNotifier<String>('All');
  final ValueNotifier<RangeValues> _filterPriceRange =
      ValueNotifier<RangeValues>(const RangeValues(100, 800));

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.flight_rounded, 'label': 'Plane'},
    {'icon': Icons.directions_bus_rounded, 'label': 'Bus'},
    {'icon': Icons.train_rounded, 'label': 'Train'},
    {'icon': Icons.hotel_rounded, 'label': 'Hotel'},
  ];

  void _toggleFavorite(String tripId) {
    final currentList = _trips.value;
    final index = currentList.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final updatedList = List<Trip>.from(currentList);
      updatedList[index] = updatedList[index].copyWith(
        isFavorite: !updatedList[index].isFavorite,
      );
      _trips.value = updatedList;
    }
  }

  List<Trip> _computeFilteredTrips() {
    final query = _searchQuery.value.toLowerCase();
    final category = _filterCategory.value;
    final priceRange = _filterPriceRange.value;

    return _trips.value.where((trip) {
      if (query.isNotEmpty) {
        final matchTitle = trip.title.toLowerCase().contains(query);
        final matchLoc = trip.location.toLowerCase().contains(query);
        final matchCountry = trip.country.toLowerCase().contains(query);
        if (!matchTitle && !matchLoc && !matchCountry) return false;
      }

      if (category != 'All' &&
          trip.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }

      if (trip.price < priceRange.start || trip.price > priceRange.end) {
        return false;
      }

      return true;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedCategory: _filterCategory.value,
        selectedTransport: _filterTransport.value,
        selectedLocation: _filterLocation.value,
        priceRange: _filterPriceRange.value,
        onApply: (category, transport, location, priceRange) {
          _filterCategory.value = category;
          _filterTransport.value = transport;
          _filterLocation.value = location;
          _filterPriceRange.value = priceRange;
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _selectedCategoryIndex.dispose();
    _navBarIndex.dispose();
    _searchQuery.dispose();
    _trips.dispose();
    _filterCategory.dispose();
    _filterTransport.dispose();
    _filterLocation.dispose();
    _filterPriceRange.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _selectedCategoryIndex,
        _navBarIndex,
        _searchQuery,
        _trips,
        _filterCategory,
        _filterTransport,
        _filterLocation,
        _filterPriceRange,
      ]),
      builder: (context, child) {
        final tripsToShow = _computeFilteredTrips();
        final nearMeTrips = tripsToShow.take(4).toList();
        final hotLocationTrips = tripsToShow.skip(2).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    constraints.maxWidth > constraints.maxHeight;
                final isTablet =
                    constraints.maxWidth >= 600 &&
                    constraints.maxHeight >= 600 &&
                    constraints.maxWidth < 1024;

                final crossAxisCount = isLandscape ? 4 : (isTablet ? 3 : 2);
                final childAspectRatio = isLandscape
                    ? 0.8
                    : (isTablet ? 0.8 : 0.72);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '2972 Westheimer, USA',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.borderLight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.03,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) {
                                        _searchQuery.value = val;
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Search hotel, location...',
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          color: AppColors.textLight,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _openFilterSheet,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(_categories.length, (
                                index,
                              ) {
                                return CategoryIconButton(
                                  icon: _categories[index]['icon'] as IconData,
                                  label: _categories[index]['label'] as String,
                                  isSelected:
                                      _selectedCategoryIndex.value == index,
                                  onTap: () {
                                    _selectedCategoryIndex.value = index;
                                  },
                                );
                              }),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Near Me',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'More',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final trip = nearMeTrips[index];
                          return TripCard(
                            trip: trip,
                            onTap: () {
                              CustomNavigator.pushFade(
                                context,
                                TripDetailScreen(trip: trip),
                              );
                            },
                            onFavoriteToggle: () => _toggleFavorite(trip.id),
                          );
                        }, childCount: nearMeTrips.length),
                      ),
                    ),
                    if (hotLocationTrips.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hot Location',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'More',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: childAspectRatio,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final trip = hotLocationTrips[index];
                            return TripCard(
                              trip: trip,
                              onTap: () {
                                CustomNavigator.pushFade(
                                  context,
                                  TripDetailScreen(trip: trip),
                                );
                              },
                              onFavoriteToggle: () => _toggleFavorite(trip.id),
                            );
                          }, childCount: hotLocationTrips.length),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _navBarIndex.value,
            onTap: (index) {
              _navBarIndex.value = index;
            },
          ),
        );
      },
    );
  }
}
