import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/reusable%20widgets/CategoriesUi.dart';
import 'package:provider/provider.dart';
import '../pages/orders_page.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../reusable widgets/HoverArchiveWidget.dart';
import '../services/orders_service.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../reusable widgets/FiltersSheet.dart';
import '../reusable widgets/Productdialogwidget.dart';
import '../reusable widgets/UiWidgets.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';
import '../services/categories_service.dart';

class PosDashboardPage extends StatefulWidget {
  const PosDashboardPage({super.key});

  @override
  State<PosDashboardPage> createState() => _PosDashboardPageState();
}

class _PosDashboardPageState extends State<PosDashboardPage> {
  // ================= DATA =================
  final postProductService _productService = postProductService();
  final ArchiveProductService _archiveProductService = ArchiveProductService();
  final FetchCategoriesService _categoriesService = FetchCategoriesService();
  final productService _service = productService();
  final searchQueryController = TextEditingController();

  // Text controllers for posting products
  final postProductNameController = TextEditingController();
  final postProductPriceController = TextEditingController();
  final postProductStorageQuantityController = TextEditingController();
  Timer? _debounceTimer; // for debouncing so i get a better ux

  // Image picking
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  // // ================= CATEGORY FILTERS =================
  // final List<String> categories = [
  //   'All',
  //   'Electronics',
  //   'LifeStyle',
  //   'Art',
  //   'Food',
  //   'Snacks',
  //   'Drinks',
  // ];//these were for the old frontend categories approch

  int selectedCategoryIndex = 0; // "All" is selected by default
  bool _sidebarExpanded = true; // Controls sidebar visibility

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    // Load initial products when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
      context.read<CategoriesProvider>().loadCategories(); // Fetch categories
    });
  }

  @override
  void dispose() {
    //for the search field
    _debounceTimer?.cancel();
    searchQueryController.dispose();

    postProductNameController.dispose();
    postProductPriceController.dispose();
    postProductStorageQuantityController.dispose();
    super.dispose();
  }

  //=========Search Handler method============

  // Real-time search with debounce it wassssss hard to look for
  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer (wait 500ms after the mr.USER to stop typing i think 500 ms is not enough imma make it longer like 750 or 1000)
    _debounceTimer = Timer(const Duration(milliseconds: 750), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    // Get the search text from the controller
    final query = searchQueryController.text.trim();

    // Get the provider and refresh with search
    final provider = context.read<ProductsProvider>();

    try {
      // Reset to first page when searching just a small method i made in the provider that only has _currentPage = 1 and thats it :)
      provider.resetPagination();

      // Fetch products with the new search query the server side one still tesingggg
      await provider.fetchProducts(
        searchQuery: query.isNotEmpty ? query : null,
      );

      // Clear focus to dismiss keyboard makes for a better ux
      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint('Search error: $e');
      // Show error to user maybe later but for now imma keep it internal only
    }
  }

  // ================= FILTER SHEET =================
  //was here now its in a seperate file in reusable widgets
  // ================= CART LOGIC =================
  void _removeFromCart(int productId) {
    context.read<CartProvider>().removeFromCart(productId);
  }

  // ================= CHECKOUT =================
  void _handleCheckout() async {
    List<Map<String, dynamic>> itemsForApi = context
        .read<CartProvider>()
        .cart
        .values
        .map(
          (item) => {"product_id": item.product.id, "quantity": item.quantity},
        )
        .toList();
    debugPrint("items for api:$itemsForApi");

    try {
      final result = await OrderService().createOrder(itemsForApi);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order #${result.id} placed! Total: \$${result.total}"),
        ),
      );

      await context.read<ProductsProvider>().refresh();
      context.read<CartProvider>().clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ================= CATEGORY SELECTION =================
  void _onCategorySelected(int categoryId, String categoryName) {
    setState(() {});

    final provider = context.read<ProductsProvider>();

    // Applying the category filter
    provider.setCategory(categoryId);
    debugPrint('Selected category: $categoryName (ID: $categoryId)');
  }

  void _onCategorySelectedAll() {
    setState(() {
      selectedCategoryIndex = 0;
    });

    final provider = context.read<ProductsProvider>();
    provider.setCategory(null);
    debugPrint('Selected category: All');
  }

  // ================= SIDEBAR WIDGET =================
  Widget _buildSidebar(
    BuildContext context,
    bool isDark,
    ProductsProvider productsProv,
  ) {
    final sidebarWidth = _sidebarExpanded
        ? 280.0
        : 100.0; // DRIVING ME CRAZYYYYYYYY

    return AnimatedContainer(
      duration: const Duration(milliseconds: 50), // MARK: SIDEBAR TIMNE
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header with Toggle
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarExpanded ? 16 : 8,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_sidebarExpanded)
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? AppColors.darkButtonsPrimary.withOpacity(0.2)
                                : AppColors.accentBlue.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.store,
                            color: isDark
                                ? AppColors.darkButtonsPrimary
                                : AppColors.accentBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'POS System',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(8),
                  //     color: isDark
                  //         ? AppColors.darkButtonsPrimary.withOpacity(0.2)
                  //         : AppColors.accentBlue.withOpacity(0.2),
                  //   ),
                  //   child: Icon(
                  //     Icons.store,
                  //     color: isDark
                  //         ? AppColors.darkButtonsPrimary
                  //         : AppColors.accentBlue,
                  //     size: 24,
                  //   ),
                  // ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDark
                          ? AppColors.darkButtonsPrimary.withOpacity(0.2)
                          : AppColors.accentBlue.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.store,
                      color: isDark
                          ? AppColors.darkButtonsPrimary
                          : AppColors.accentBlue,
                      size: 24,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _sidebarExpanded = !_sidebarExpanded;
                    });
                  },
                  tooltip: _sidebarExpanded
                      ? 'Collapse sidebar'
                      : 'Expand sidebar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),

          // Sidebar Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Theme Toggle
                  buildSidebarMenuItem(
                    icon: Icons.light_mode,
                    label: 'Theme',
                    isDark: isDark,
                    onTap: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                    isExpanded: _sidebarExpanded,
                  ),

                  // Refresh Button
                  buildSidebarMenuItem(
                    icon: Icons.refresh,
                    label: 'Refresh',
                    isDark: isDark,
                    onTap: () {
                      productsProv.refresh();
                      context.read<CategoriesProvider>().loadCategories();
                    },
                    isExpanded: _sidebarExpanded,
                  ),

                  // Add Category Button
                  buildSidebarMenuItem(
                    icon: Icons.add,
                    label: 'Add Category',
                    isDark: isDark,
                    onTap: () async {
                      final success = await showDialog<bool>(
                        context: context,
                        builder: (context) => const AddCategoryDialog(),
                      );
                      if (success == true) {
                        context.read<CategoriesProvider>().loadCategories();
                      }
                    },
                    isExpanded: _sidebarExpanded,
                  ),

                  // Orders Button
                  buildSidebarMenuItem(
                    icon: Icons.receipt_long,
                    label: 'Orders',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersPage(),
                        ),
                      );
                    },
                    isExpanded: _sidebarExpanded,
                  ),

                  // Filter Button
                  buildSidebarMenuItem(
                    icon: Icons.filter_list,
                    label: 'Filters',
                    isDark: isDark,
                    onTap: () {
                      openFilterSheet(context);
                    },
                    isExpanded: _sidebarExpanded,
                  ),

                  // Add Product Button
                  buildSidebarMenuItem(
                    icon: Icons.add,
                    label: 'Add Product',
                    isDark: isDark,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const Productdialogwidget(),
                      );
                    },
                    isExpanded: _sidebarExpanded,
                  ),

                  // Separator
                  if (_sidebarExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Divider(
                        color: isDark
                            ? AppColors.borderSubtle
                            : Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),

                  // System Settings ( needed later)
                  if (_sidebarExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SYSTEM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildSidebarMenuItem(
                            icon: Icons.settings,
                            label: 'Settings',
                            isDark: isDark,
                            onTap: () {}, //forlater
                            isExpanded: _sidebarExpanded,
                          ),
                          buildSidebarMenuItem(
                            icon: Icons.help_outline,
                            label: 'Help',
                            isDark: isDark,
                            onTap: () {}, //forlaterr
                            isExpanded: _sidebarExpanded,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // User Profile Section
          Container(
            padding: EdgeInsets.all(_sidebarExpanded ? 16 : 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark
                        ? AppColors.darkButtonsPrimary
                        : AppColors.accentBlue,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hamza Akkad',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'hamzakkad@pos.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.watch<ThemeProvider>().isDark
            ? AppColors.darkBgPrimary
            : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isDark = context.watch<ThemeProvider>().isDark;
            final productsProv = context.watch<ProductsProvider>();

            // Responsive calculations
            final cartPanelWidth = screenWidth > 1200
                ? 370
                : screenWidth > 800
                ? 360 //MARK: WIDTH
                : 340;

            final gridCrossAxisCount = screenWidth > 1400
                ? 5
                : screenWidth > 1100
                ? 4
                : screenWidth > 800
                ? 3
                : screenWidth > 600
                ? 2
                : 1;

            final gridChildAspectRatio = screenWidth > 1400
                ? 0.85
                : screenWidth > 1100
                ? 0.9
                : screenWidth > 800
                ? 1.0
                : 1.2;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= SIDEBAR =================
                _buildSidebar(context, isDark, productsProv),

                // ================= MAIN CONTENT =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Clean Search Header
                      Container(
                        height: 80,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 800 ? 24 : 16,
                        ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Search field
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkButtonsPrimary
                                        : Colors.transparent,
                                  ),
                                  color: isDark
                                      ? AppColors.darkBgSurface
                                      : AppColors.lightBgSurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: searchQueryController,
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search...',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            color: isDark
                                                ? AppColors.darkTextMuted
                                                : AppColors.lightTextMuted,
                                          ),
                                          suffixIcon:
                                              searchQueryController
                                                  .text
                                                  .isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(
                                                    Icons.clear,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    searchQueryController
                                                        .clear();
                                                    _performSearch();
                                                  },
                                                )
                                              : null,
                                        ),
                                        onSubmitted: (value) =>
                                            _performSearch(),
                                        onChanged: _onSearchChanged,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ================= FILTER & CATEGORIES BAR =================
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: Consumer<ProductsProvider>(
                          builder: (context, productsProv, _) {
                            return Row(
                              children: [
                                // Scrollable Categories from Provider
                                Expanded(
                                  child: Consumer<CategoriesProvider>(
                                    builder: (context, categoriesProvider, child) {
                                      if (categoriesProvider.isLoading) {
                                        return const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }

                                      if (categoriesProvider
                                          .errorMessage
                                          .isNotEmpty) {
                                        return Center(
                                          child: Text(
                                            'Error: ${categoriesProvider.errorMessage}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }

                                      if (categoriesProvider
                                          .categories
                                          .isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'No categories',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      }

                                      // Add "All" category at the beginning
                                      final allCategories = [
                                        {'id': 0, 'name': 'All', 'isAll': true},
                                        ...categoriesProvider.categories.map(
                                          (cat) => {
                                            'id': cat.id,
                                            'name': cat.name,
                                            'isAll': false,
                                          },
                                        ),
                                      ];

                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 8,
                                        ),
                                        itemCount: allCategories.length,
                                        itemBuilder: (context, index) {
                                          final category = allCategories[index];
                                          final isAll =
                                              category['isAll'] as bool;
                                          final categoryId =
                                              category['id'] as int;
                                          final categoryName =
                                              category['name'] as String;

                                          final isSelected =
                                              (isAll &&
                                                  selectedCategoryIndex == 0) ||
                                              (!isAll &&
                                                  productsProv.category_id ==
                                                      categoryId);

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Container(
                                              height: 36,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (isAll) {
                                                    _onCategorySelectedAll();
                                                  } else {
                                                    _onCategorySelected(
                                                      categoryId,
                                                      categoryName,
                                                    );
                                                  }
                                                }, //MARK: ALL BUTTON
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isSelected
                                                      ? (isDark
                                                            ? AppColors
                                                                  .darkButtonsPrimary
                                                            : AppColors
                                                                  .accentBlue)
                                                      : (isDark
                                                            ? AppColors
                                                                  .darkBgElevated
                                                            : Colors
                                                                  .grey
                                                                  .shade100),
                                                  foregroundColor: isSelected
                                                      ? (isDark
                                                            ? AppColors
                                                                  .darkTextPrimary
                                                            : Colors.white)
                                                      : (isDark
                                                            ? AppColors
                                                                  .darkTextMuted
                                                            : Colors
                                                                  .grey
                                                                  .shade800),
                                                  elevation: 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    side: BorderSide(
                                                      color: isSelected
                                                          ? Colors.transparent
                                                          : (isDark
                                                                ? AppColors
                                                                      .darkButtonsPrimary
                                                                : AppColors
                                                                      .accentBlue),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  categoryName,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),

                                // More Compact Pagination
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          size: 14,
                                        ),
                                        color: isDark
                                            ? AppColors.darkButtonsPrimary
                                            : AppColors.accentBlue,
                                        onPressed: productsProv.currentPage > 1
                                            ? () => productsProv.previousPage()
                                            : null,
                                      ),
                                      Container(
                                        height: 36,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'P. ${productsProv.currentPage}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                        ),
                                        color: isDark
                                            ? AppColors.darkButtonsPrimary
                                            : AppColors.accentBlue,
                                        onPressed: () {
                                          productsProv.nextPage();
                                          productsProv.loadMoreProducts();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Products Grid
                      Expanded(
                        child: Container(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : AppColors.lightBgSurface,
                          padding: EdgeInsets.all(screenWidth > 800 ? 12 : 12),
                          child: Consumer<ProductsProvider>(
                            builder: (context, productsProv, _) {
                              if (productsProv.loading &&
                                  productsProv.products.isEmpty) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: isDark
                                        ? AppColors.darkButtonsPrimary
                                        : Color(0xFF0277FA),
                                  ),
                                );
                              }

                              if (productsProv.error != null &&
                                  productsProv.products.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        productsProv.error!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () => productsProv.refresh(),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: gridCrossAxisCount,
                                      crossAxisSpacing: screenWidth > 800
                                          ? 16
                                          : 12,
                                      mainAxisSpacing: screenWidth > 800
                                          ? 16
                                          : 12,
                                      childAspectRatio: gridChildAspectRatio,
                                    ),
                                itemCount: productsProv.products.length + (0),
                                itemBuilder: (_, i) {
                                  final p = productsProv.products[i];

                                  return SubtleHoverDelete(
                                    child: GestureDetector(
                                      onTap: () => context
                                          .read<CartProvider>()
                                          .addToCart(p),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkBgSurface
                                              : AppColors.lightBgSurface,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? AppColors.darkButtonsPrimary
                                                        .withOpacity(0.09)
                                                  : AppColors.accentBlue
                                                        .withOpacity(0.09),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product Image
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? AppColors.darkBgElevated
                                                      : Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(12),
                                                      ),
                                                ),
                                                child:
                                                    p.imageUrl != null &&
                                                        p.imageUrl!.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                        child: Image.network(
                                                          p.imageUrl!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    color:
                                                                        isDark
                                                                        ? AppColors
                                                                              .danger
                                                                        : Colors
                                                                              .grey
                                                                              .shade400,
                                                                    size: 32,
                                                                  ),
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : Center(
                                                        child: Icon(
                                                          Icons.image,
                                                          color: isDark
                                                              ? AppColors
                                                                    .borderSubtle
                                                              : Colors
                                                                    .grey
                                                                    .shade400,
                                                          size: 40,
                                                        ),
                                                      ),
                                              ),
                                            ),

                                            // Product Info
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth > 800
                                                          ? 12
                                                          : 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isDark
                                                          ? AppColors
                                                                .darkTextSecondary
                                                          : AppColors
                                                                .lightTextPrimary,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '\$${p.price.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize:
                                                              screenWidth > 800
                                                              ? 14
                                                              : 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? AppColors
                                                                    .darkButtonsPrimary
                                                              : AppColors
                                                                    .accentBlue,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isDark
                                                              ? p.stock <= 5
                                                                    ? AppColors
                                                                          .borderSubtle
                                                                    : p.stock <=
                                                                          20
                                                                    ? AppColors
                                                                          .borderSubtle
                                                                    : AppColors
                                                                          .borderSubtle
                                                              : p.stock <= 5
                                                              ? Colors
                                                                    .red
                                                                    .shade50
                                                              : p.stock <= 20
                                                              ? Colors
                                                                    .orange
                                                                    .shade50
                                                              : Colors
                                                                    .green
                                                                    .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                          border: Border.all(
                                                            color: p.stock <= 5
                                                                ? Colors
                                                                      .red
                                                                      .shade200
                                                                : p.stock <= 20
                                                                ? Colors
                                                                      .orange
                                                                      .shade200
                                                                : Colors
                                                                      .green
                                                                      .shade200,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          '${p.stock} left',
                                                          style: TextStyle(
                                                            fontSize:
                                                                screenWidth >
                                                                    800
                                                                ? 11
                                                                : 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: p.stock <= 5
                                                                ? Colors
                                                                      .red
                                                                      .shade700
                                                                : p.stock <= 20
                                                                ? Colors
                                                                      .orange
                                                                      .shade700
                                                                : Colors
                                                                      .green
                                                                      .shade700,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onArchive: () {
                                      ProductdialogwidgetState.archiveProduct(
                                        context,
                                        p.id,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= RIGHT ORDER PANEL =================
                Container(
                  width: cartPanelWidth.toDouble(),
                  height: double.infinity,
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkButtonsPrimary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Order Header
                      Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
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
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isDark
                                    ? AppColors.darkButtonsPrimary.withOpacity(
                                        0.1,
                                      )
                                    : AppColors.accentBlue.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.shopping_bag,
                                color: isDark
                                    ? AppColors.darkButtonsPrimary
                                    : AppColors.accentBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (context.watch<CartProvider>().cart.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear_all,
                                  color: isDark
                                      ? AppColors.darkButtonsPrimary
                                      : AppColors.accentBlue,
                                  size: 22,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Clear Cart'),
                                      content: const Text(
                                        'Are you sure you want to clear all items from the cart?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<CartProvider>()
                                                .clearCart();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Clear'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'Clear Cart',
                              ),
                          ],
                        ),
                      ),

                      // Order Items
                      Expanded(
                        child: context.watch<CartProvider>().cart.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.grey.shade300,
                                        size: screenHeight * 0.15,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'No items in cart',
                                        style: TextStyle(
                                          fontSize: screenWidth > 800 ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add products to cart',
                                        style: TextStyle(
                                          fontSize: screenWidth > 800 ? 14 : 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: context
                                    .watch<CartProvider>()
                                    .cart
                                    .length,
                                itemBuilder: (_, i) {
                                  final item = context
                                      .watch<CartProvider>()
                                      .cart
                                      .values
                                      .elementAt(i);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkBgElevated
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade500,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.darkButtonsPrimary
                                              .withOpacity(0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.product.name,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? AppColors
                                                            .darkTextSecondary
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors
                                                          .darkButtonsPrimary
                                                    : AppColors.accentBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${item.quantity}x @ \$${item.product.price.toStringAsFixed(2)} each',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : Colors.black,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.remove,
                                                      size: 18,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    onPressed: () =>
                                                        _removeFromCart(
                                                          item.product.id,
                                                        ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 36,
                                                          minHeight: 36,
                                                        ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .darkTextMuted,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.add,
                                                      size: 18,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    onPressed: () => context
                                                        .read<CartProvider>()
                                                        .addToCart(
                                                          item.product,
                                                        ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 36,
                                                          minHeight: 36,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Order Summary
                      if (context.watch<CartProvider>().cart.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(screenWidth > 800 ? 24 : 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBgElevated
                                : Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? AppColors.darkBgSurface
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkButtonsPrimary.withOpacity(
                                  0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    '\$${(context.watch<CartProvider>().cart.values.fold<double>(0, (s, i) => s + i.total)).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkButtonsPrimary
                                          : AppColors.accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _handleCheckout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.darkButtonsPrimary
                                        : AppColors.accentBlue,
                                    foregroundColor: isDark
                                        ? AppColors.darkTextPrimary
                                        : Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Pay Now',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
