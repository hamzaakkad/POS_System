import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_system/reusable%20widgets/EditProductDialogWidget.dart';
import 'package:pos_system/reusable%20widgets/Productdialogwidget.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  final Set<int> _expandedProducts = {};
  final ScrollController _scrollController = ScrollController();
  final searchQueryController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductsProvider>().fetchProductsPageProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchQueryController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = searchQueryController.text.trim();
    final provider = context.read<ProductsProvider>();
    try {
      provider.resetPagePagination();
      await provider.fetchProductsPageProducts(
        searchQuery: query.isNotEmpty ? query : null,
      );
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _performSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final provider = context.watch<ProductsProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(screenWidth, isDark, provider),
                    const SizedBox(height: 24),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgElevated
                              : AppColors.lightBgElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderSubtle
                                : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.4 : 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSearchSection(isDark, screenWidth, provider),
                            _tableHeader(screenWidth, isDark),
                            Container(
                              height: 1,
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: _buildListContent(
                                provider,
                                isDark,
                                screenWidth,
                              ),
                            ),
                            _buildPaginationFooter(provider, isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    double screenWidth,
    bool isDark,
    ProductsProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Text(
          'PRODUCTS',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontSize: screenWidth > 800 ? 28 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
              ),
              onPressed: () {
                _openFiltersSheet(context);
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark, double screenWidth, ProductsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchQueryController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _performSearch(),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search products...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBgPrimary
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: searchQueryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          searchQueryController.clear();
                          _performSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => const Productdialogwidget(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkButtonsPrimary
                  : AppColors.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "ADD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(double screenWidth, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 15,
      ),
      child: Row(
        children: [
          _HeaderText(
            'NAME',
            flex: 3,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          if (screenWidth > 600)
            _HeaderText(
              'ID',
              flex: 2,
              screenWidth: screenWidth,
              isDark: isDark,
            ),
          _HeaderText(
            'PRICE',
            flex: 2,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          const SizedBox(width: 96),
        ],
      )
    );
  }

  Widget _buildListContent(
    ProductsProvider provider,
    bool isDark,
    double screenWidth,
  ) {
    if (provider.pageLoading && provider.productsPageProducts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }

    if (provider.productsPageProducts.isEmpty) {
      return Center(
        child: Text(
          "No products found.",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.productsPageProducts.length,
      itemBuilder: (context, index) {
        final product = provider.productsPageProducts[index];
        final expanded = _expandedProducts.contains(product.id);

        return Column(
          children: [
            _productRow(product, expanded, screenWidth, isDark),
            if (expanded) _productDetails(product, isDark),
          ],
        );
      },
    );
  }

  Widget _productRow(
    productPageModel product,
    bool expanded,
    double screenWidth,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: expanded
            ? (isDark ? Colors.white10 : Colors.blue.withOpacity(0.05))
            : null,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderSubtle : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(product.name, style: _rowStyle(isDark, bold: true)),
          ),
          if (screenWidth > 600)
            Expanded(
              flex: 2,
              child: Text('#${product.id}', style: _rowStyle(isDark)),
            ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkButtonsPrimary
                    : AppColors.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.yellow.shade200),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        EditProductDialogWidget(product: product.toJson()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () =>
                    context.read<ProductsProvider>().archiveProduct(product.id),
              ),
              IconButton(
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: () => setState(() {
                  expanded
                      ? _expandedProducts.remove(product.id)
                      : _expandedProducts.add(product.id);
                }),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _productDetails(productPageModel product, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: isDark ? Colors.black26 : Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Inventory Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkButtonsPrimary
                  : AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text("Current Stock: ${product.stock}", style: _rowStyle(isDark)),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(ProductsProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgElevated : Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page ${provider.pageCurrentPage}", style: _rowStyle(isDark)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.pageCurrentPage > 1
                    ? () => provider.previousPagePage()
                    : null,
              ),
              if (provider.pageLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.accentBlue,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      (provider.pageHasMore ||
                          provider.pageCurrentPage < provider.pageTotalPages)
                      ? () => provider.nextPagePage()
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _rowStyle(bool isDark, {bool bold = false}) => TextStyle(
    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontSize: 15,
  );

  void _openFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final provider = context.read<ProductsProvider>();
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().isDark
                    ? AppColors.darkBgElevated
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.watch<ThemeProvider>().isDark
                                ? AppColors.darkTextPrimary
                                : Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFilterSection(
                      'Stock Status',
                      [
                        _buildFilterOption(
                          'In Stock Only',
                          provider.inStockPage,
                          (value) {
                            setModalState(() {
                              provider.setPageInStockOnly(value);
                            });
                          },
                          context,
                        ),
                        _buildFilterOption(
                          'Out of Stock Only',
                          provider.outOfStockPage,
                          (value) {
                            setModalState(() {
                              provider.setPageOutOfStockOnly(value);
                            });
                          },
                          context,
                        ),
                      ],
                      context,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildFilterSection(
                      'Sort By',
                      [
                        _buildFilterOption(
                          'A to Z',
                          provider.sortAtoZPage == true,
                          (value) {
                            setModalState(() {
                              provider.setPageSortByName(value);
                            });
                          },
                          context,
                        ),
                        _buildFilterOption(
                          'Z to A',
                          provider.sortZtoAPage == true,
                          (value) {
                            setModalState(() {
                              provider.setPageSortByNameDESC(value);
                            });
                          },
                          context,
                        ),
                      ],
                      context,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildPriceRangeFilter(provider, setModalState, context),
                    
                    const SizedBox(height: 30),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              provider.resetPageFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.watch<ThemeProvider>().isDark
                                  ? AppColors.danger
                                  : Colors.red.shade500,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              provider.fetchProductsPageProducts();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.watch<ThemeProvider>().isDark
                                  ? AppColors.darkButtonsPrimary
                                  : AppColors.accentBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<Widget> options,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.watch<ThemeProvider>().isDark
                ? AppColors.darkTextSecondary
                : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        ...options,
      ],
    );
  }

  Widget _buildFilterOption(
    String label,
    bool value,
    Function(bool) onChanged,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: context.watch<ThemeProvider>().isDark
                ? AppColors.darkButtonsPrimary
                : AppColors.accentBlue,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: context.watch<ThemeProvider>().isDark
                  ? AppColors.darkTextPrimary
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter(
    ProductsProvider provider,
    StateSetter setModalState,
    BuildContext context,
  ) {
    final minController = TextEditingController(text: provider.minPricePage?.toString() ?? '');
    final maxController = TextEditingController(text: provider.maxPricePage?.toString() ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.watch<ThemeProvider>().isDark
                ? AppColors.darkTextSecondary
                : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                decoration: InputDecoration(
                  labelText: 'Min Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setModalState(() {
                    provider.setPageMinPrice(value.isEmpty ? null : int.tryParse(value));
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxController,
                decoration: InputDecoration(
                  labelText: 'Max Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setModalState(() {
                    provider.setPageMaxPrice(value.isEmpty ? null : int.tryParse(value));
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final int flex;
  final double screenWidth;
  final bool isDark;
  const _HeaderText(
    this.text, {
    required this.flex,
    required this.screenWidth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
          fontSize: screenWidth > 800 ? 13 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}