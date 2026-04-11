import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _recentSearches = [];
  bool _showFilters = false;
  RangeValues _priceRange = const RangeValues(0, 5000);
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches =
          prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList(AppConstants.recentSearchesKey, _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.recentSearchesKey);
    setState(() => _recentSearches = []);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _saveSearch(query.trim());
    ref.read(searchQueryProvider.notifier).state = query.trim();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Search flowers, gifts...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.white),
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: query.isEmpty
                  ? _buildRecentSearches()
                  : results.when(
                      data: (products) => products.isEmpty
                          ? _buildEmptyState()
                          : _buildResultsGrid(products),
                      loading: () => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (e, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text('Something went wrong',
                                style: AppTextStyles.body1),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.invalidate(searchResultsProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text('Search for flowers & gifts',
                style: AppTextStyles.body1.copyWith(color: AppColors.grey500)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: AppTextStyles.h3),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((s) {
              return ActionChip(
                label: Text(s),
                avatar: const Icon(Icons.history, size: 16),
                onPressed: () {
                  _controller.text = s;
                  _performSearch(s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text('No Results Found', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return GestureDetector(
          onTap: () => context.push('/product/${p.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(p.vendorName ?? '',
                            style: AppTextStyles.caption,
                            maxLines: 1),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.currencySymbol} ${p.price.toStringAsFixed(0)}',
                              style: AppTextStyles.priceSmall,
                            ),
                            const Spacer(),
                            const Icon(Icons.star,
                                size: 14, color: AppColors.starGold),
                            Text(p.averageRating.toStringAsFixed(1),
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filters', style: AppTextStyles.h2),
              const SizedBox(height: 20),
              Text('Price Range', style: AppTextStyles.body1),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 10000,
                divisions: 100,
                activeColor: AppColors.primary,
                labels: RangeLabels(
                  '${AppConstants.currencySymbol} ${_priceRange.start.toInt()}',
                  '${AppConstants.currencySymbol} ${_priceRange.end.toInt()}',
                ),
                onChanged: (v) => setModalState(() => _priceRange = v),
              ),
              const SizedBox(height: 16),
              Text('Sort By', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Popular', 'Price: Low', 'Price: High', 'Newest']
                    .map((s) => ChoiceChip(
                          label: Text(s),
                          selected: _selectedSort == s,
                          selectedColor: AppColors.primaryLight,
                          onSelected: (v) =>
                              setModalState(() => _selectedSort = v ? s : null),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(productFilterProvider.notifier).state =
                        ProductFilter(
                      priceMin: _priceRange.start,
                      priceMax: _priceRange.end,
                      sortBy: _selectedSort,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
