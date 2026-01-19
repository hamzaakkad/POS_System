import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/orders_page.dart';
import '../services/product_service.dart';
import '../services/orders_service.dart';
import '../models/product_model.dart';

import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';

import '../reusable widgets/HoverArchiveWidget.dart';
import '../reusable widgets/FiltersSheet.dart';
import '../reusable widgets/Productdialogwidget.dart';
import 'reusable widgets/UiWidgets.dart';
import 'reusable widgets/AppColors.dart';

import 'package:image_picker/image_picker.dart';

class PosDashboardPage extends StatefulWidget {
  const PosDashboardPage({super.key});

  @override
  State<PosDashboardPage> createState() => _PosDashboardPageState();
}

class _PosDashboardPageState extends State<PosDashboardPage> {
  final postProductService _productService = postProductService();
  final ArchiveProductService _archiveProductService = ArchiveProductService();
  final productService _service = productService();

  final searchQueryController = TextEditingController();
  final postProductNameController = TextEditingController();
  final postProductPriceController = TextEditingController();
  final postProductStorageQuantityController = TextEditingController();

  Timer? _debounceTimer;

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchQueryController.dispose();
    postProductNameController.dispose();
    postProductPriceController.dispose();
    postProductStorageQuantityController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final query = searchQueryController.text.trim();
    final provider = context.read<ProductsProvider>();

    provider.resetPagination();
    await provider.fetchProducts(
      searchQuery: query.isNotEmpty ? query : null,
    );
    FocusScope.of(context).unfocus();
  }

  void _removeFromCart(int productId) {
    context.read<CartProvider>().removeFromCart(productId);
  }

  void _handleCheckout() async {
    final itemsForApi = context
        .read<CartProvider>()
        .cart
        .values
        .map((e) => {"product_id": e.product.id, "quantity": e.quantity})
        .toList();

    try {
      final result = await OrderService().createOrder(itemsForApi);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order #${result.id} placed")),
      );
      context.read<ProductsProvider>().refresh();
      context.read<CartProvider>().clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final productsProv = context.watch<ProductsProvider>();

    return Scaffold(
      body: Container(
        color: isDark
            ? AppColors.darkBgPrimary
            : AppColors.lightBgPrimary,
        child: Row(
          children: [
            // ================= LEFT PANEL =================
            Expanded(
              child: Column(
                children: [
                  // HEADER
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBgElevated
                          : AppColors.lightBgElevated,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? AppColors.borderSubtle
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 🌗 THEME TOGGLE
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          onPressed: () =>
                              context.read<ThemeProvider>().toggleTheme(),
                        ),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBgSurface
                                  : AppColors.lightBgSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(Icons.search,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: searchQueryController,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search products...',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                    onChanged: _onSearchChanged,
                                    onSubmitted: (_) => _performSearch(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const Productdialogwidget(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("ADD"),
                        ),
                      ],
                    ),
                  ),

                  // PRODUCTS GRID
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: productsProv.products.length,
                      itemBuilder: (_, i) {
                        final p = productsProv.products[i];
                        return SubtleHoverDelete(
                          onArchive: () {
                            ProductdialogwidgetState.archiveProduct(
                              context,
                              p.id,
                            );
                          },
                          child: GestureDetector(
                            onTap: () =>
                                context.read<CartProvider>().addToCart(p),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBgSurface
                                    : AppColors.lightBgSurface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        isDark ? 0.4 : 0.08),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ================= RIGHT CART =================
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBgSurface
                    : AppColors.lightBgSurface,
                border: Border(
                  left: BorderSide(
                    color: isDark
                        ? AppColors.borderSubtle
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Order Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Pay Now"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
