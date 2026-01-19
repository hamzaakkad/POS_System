import 'dart:async';
import 'package:flutter/material.dart';
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
      context.read<ProductsProvider>().fetchProducts();
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
      provider.resetPagination();
      await provider.fetchProducts(
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

                    /// PRODUCT MANAGEMENT BOX (Matching Categories Design)
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
                            _buildSearchSection(isDark, screenWidth),
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
          onPressed: () => Navigator.pop(context),
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
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () => provider.refresh(),
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark, double screenWidth) {
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
          const SizedBox(width: 96), // Space for icons
        ],
      ),
    );
  }

  Widget _buildListContent(
    ProductsProvider provider,
    bool isDark,
    double screenWidth,
  ) {
    if (provider.loading && provider.products.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accentBlue),
      );
    }
    if (provider.products.isEmpty) {
      return Center(
        child: Text(
          "No products found.",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
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
    productModel product,
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
      ),
    );
  }

  Widget _productDetails(productModel product, bool isDark) {
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
          Text("Page ${provider.currentPage}", style: _rowStyle(isDark)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.currentPage > 1
                    ? () => provider.previousPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: (provider.hasMore)
                    ? () => provider.nextPage()
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
