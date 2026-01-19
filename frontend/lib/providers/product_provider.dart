import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/categories_service.dart';

class ProductsProvider extends ChangeNotifier {
  final productService _service = productService();
  final postProductService _postService = postProductService();
  final ArchiveProductService _archiveService = ArchiveProductService();
  final FetchCategoriesService _categoriesService = FetchCategoriesService();

  // Product lists
  final List<productModel> _allProducts = [];
  final List<productModel> _filteredProducts = [];

  // Search and filter states
  String _searchQuery = '';
  int? minPrice;
  int? maxPrice;
  bool _inStockOnly = false;
  bool _outOfStockOnly = false;
  int? _lowStockThreshold;
  bool _sortByPriceAsc = false;
  bool _sortByNameAsc = false;
  int? category_id;

  // Loading and error states
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  // Pagination states
  bool _hasMore = true; // Server-side pagination flag
  int _currentPage =
      1; // Client-side pagination for filtered results please engineer dont ask me to make the filtering server side
  final int _itemsPerPage = 20;
  int allPages = 1;
  bool? sortAtoZ = false;
  bool? sortZtoA = false;
  bool inStock = false;
  bool outOfStock = false;

  // Getters
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  bool get inStockOnly => _inStockOnly;
  bool get outOfStockOnly => _outOfStockOnly;

  int? get lowStockThreshold => _lowStockThreshold;
  int? get selectedCategoryId => category_id; //this one caused me bugs

  // Get total pages for filtered results and for the ui flags
  int get totalPages {
    if (_filteredProducts.isEmpty) return 1;
    return (_filteredProducts.length / _itemsPerPage).ceil().clamp(1, 999);
  } // it didnt work for the ui so imma keep it for the filtered results only

  // Get products for current page (client-side pagination) now dont tell me delete this i made them work together :)
  UnmodifiableListView<productModel> get products {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (start >= _filteredProducts.length) {
      return UnmodifiableListView([]);
    }

    final pageItems = _filteredProducts.sublist(
      start,
      end > _filteredProducts.length ? _filteredProducts.length : end,
    );

    return UnmodifiableListView(pageItems);
  }

  // Get all filtered products (for reference)
  UnmodifiableListView<productModel> get allFilteredProducts {
    return UnmodifiableListView(_filteredProducts);
  }

  // === FETCH PRODUCTS ===

  Future<void> fetchProducts({
    // bool? sort_AtoZ,
    String? searchQuery,
    //int? minPrice, // this works it sends data to the service
    //int? maxPrice, // so as this
  }) async {
    _loading = true;
    _error = null;
    _hasMore = true; // Reset for new fetch
    notifyListeners();
    // allPages = _allProducts.length.toInt() ~/ 20;

    try {
      final fetched = await _service.fetchProducts(
        category: category_id,
        inStock: inStock,
        outOfStock: outOfStock,
        sort_ZtoA: sortZtoA,
        sort_AtoZ: sortAtoZ,
        loadMore: false,
        searchQuery: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      // debugPrint(
      //   "fetchProducts in productprovider recieved minimum price of : $minPrice",
      // );
      // debugPrint("sort A to Z in the provider is : $sort_AtoZ in the try block inside fetchProduct void function");
      _allProducts
        ..clear()
        ..addAll(fetched);

      // Check if server has more products change the flag depending on it to true or false and depending on this flag imma stop or keep the function working
      _hasMore = _service.currentCursor != null;

      _applySearchAndFilters();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching productssssssssss: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  setMinPrice(int? minimumPrice) async {
    minPrice = minimumPrice;
    //_currentPage = 1;
    resetPagination();
    debugPrint("set minimum price method recieved : $minimumPrice");
    // fetchProducts(minPrice = minimumPrice);
    // await fetchProducts();
    await refresh();
    _applySearchAndFilters();
  }

  setMaxPrice(int? maximumPrice) async {
    maxPrice = maximumPrice;
    //_currentPage = 1;
    resetPagination(); // same as calling _currentPage = 1; but thats a more decorated way ;))
    debugPrint("set MAXIMUM price method recieved : $maximumPrice");
    // fetchProducts(minPrice = minimumPrice);
    // await fetchProducts();
    await refresh(); // why refresh because refresh in its core is just calling fetchProducts so its the same ;) just the rename is for conflict in the code
    _applySearchAndFilters();
  }

  setCategory(int? category) {
    category_id = category;
    resetPagination();
    refresh();
  }

  // Category mapping there is one like it in the pos_dashboard.dart actually there are 2
  final Map<String, int?> categoryMapping = {
    'All': null,
    'Electronics': 1,
    'LifeStyle': 2,
    'Art': 3,
    'Food': 4,
    'Snacks': 5,
    'Drinks': 6,
  };

  //======= reset pagination method ========= im currently using it with the server side search and filters see pos_dashbord perform search method
  resetPagination() {
    _currentPage = 1;
  }

  // === LOAD MORE PRODUCTS (Server-side) ===
  // this was terrifieng
  Future<void> loadMoreProducts() async {
    if (_loadingMore || !_hasMore) return;
    // allPages = products.length.toInt() ~/ 20; // this didnt work so its useless rn imma keep it for the next cleanUP^
    _loadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final newProducts = await _service.fetchProducts(
        category: category_id,

        sort_ZtoA: sortZtoA,
        sort_AtoZ: sortAtoZ,
        loadMore: true,
        minPrice: minPrice, //this bug was easier that i thought to fix
        maxPrice: maxPrice, // ya it was :)
      );

      // Append new products to existing list
      _allProducts.addAll(newProducts);

      // Update hasMore flag for the same reasons ive mentioned earlier
      _hasMore = _service.currentCursor != null;

      // Re-apply filters to include new products please for the third time engineer dont ask me to make the filters server based

      _applySearchAndFilters();

      debugPrint(
        'Loaded ${newProducts.length} more products. Total: ${_allProducts.length}, Has more: $_hasMore',
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading more products: $e');
      rethrow;
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  // === REFRESH ===
  Future<void> refresh() => fetchProducts(); // cool rename

  // === POST PRODUCT ===
  Future<void> postProduct(productModel product) async {
    _loading = true;
    notifyListeners();
    try {
      await _postService.postProduct(product);
      await fetchProducts(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  // === ARCHIVE PRODUCT ===
  Future<void> archiveProduct(int id) async {
    try {
      await _archiveService.archiveProduct(id);

      // Remove from both lists
      _allProducts.removeWhere((p) => p.id == id);
      //while i think removing it only from _filteredProducts is enough but i dont wanna have some bugs and so
      _filteredProducts.removeWhere((p) => p.id == id);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // === SEARCH AND FILTERS ===
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _currentPage = 1; // Reset to first page on search
    _applySearchAndFilters();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    _applySearchAndFilters();
  }

  void setInStockOnly(bool value) {
    resetPagination();
    // _inStockOnly = value;
    // _outOfStockOnly = false; // Mutual exclusion cool in the ui
    inStock = value; // for the backend
    outOfStock = false; // for the backend
    refresh();
    _applySearchAndFilters();
  }

  void setOutOfStockOnly(bool value) {
    // _currentPage = 1;
    resetPagination();

    // _outOfStockOnly = value;
    // _inStockOnly =
    //     false; // Mutual exclusion looks amazing in the ui material.dart its an amazing library for customization
    outOfStock = value; // for the backend
    inStock = false; // for the backend
    refresh();
    _applySearchAndFilters();
  }

  void setLowStockThreshold(int? value) {
    _currentPage = 1;
    _lowStockThreshold = value;
    _applySearchAndFilters();
  }

  void sortByPrice(bool ascending) {
    _currentPage = 1;
    _sortByPriceAsc = ascending;
    _sortByNameAsc = false;
    _applySearchAndFilters();
  }

  void sortByName(bool ascending) {
    _currentPage = 1;
    // _sortByNameAsc = ascending;
    sortAtoZ = true;
    sortZtoA = false;

    _sortByPriceAsc = false;
    refresh();
    _applySearchAndFilters();
  }

  void sortByNameDESC(bool descending) {
    _currentPage = 1;
    // _sortByNameAsc = ascending;
    sortAtoZ = false;
    sortZtoA = true;

    _sortByPriceAsc = false;
    refresh();
    _applySearchAndFilters();
  }

  void resetFilters() {
    _currentPage = 1;
    _searchQuery = '';
    minPrice = null;
    maxPrice = null;
    _inStockOnly = false;
    _outOfStockOnly = false;
    _lowStockThreshold = null;
    _sortByPriceAsc = false;
    _sortByNameAsc = false;
    sortAtoZ = false;
    sortZtoA = false;
    inStock = false;
    outOfStock = false;
    category_id = null;

    refresh();
    _applySearchAndFilters();
  }

  // === APPLY SEARCH AND FILTERS ===
  void _applySearchAndFilters() {
    List<productModel> result = List.from(_allProducts);

    //SEARCH
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // FILTERS
    if (_inStockOnly) {
      result = result.where((p) => p.stock > 0).toList();
    }

    if (_outOfStockOnly) {
      result = result.where((p) => p.stock == 0).toList();
    }

    if (_lowStockThreshold != null) {
      result = result
          .where((p) => p.stock > 0 && p.stock <= _lowStockThreshold!)
          .toList();
    }

    // SORT
    if (_sortByPriceAsc) {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortByNameAsc) {
      result.sort((a, b) => a.name.compareTo(b.name));
    }

    // Update filtered list
    _filteredProducts
      ..clear()
      ..addAll(result);

    // Ensure current page is valid
    if (_currentPage > totalPages) {
      _currentPage = totalPages > 0 ? totalPages : 1;
    }

    notifyListeners();
  }

  // === PAGINATION METHODS (Client-side for filtered results) ===
  Future<void> nextPage() async {
    if (_currentPage < totalPages) {
      // Regular pagination within filtered results i dont have to mention anything mrs.engineer please dont make me make this server based
      _currentPage++;
      notifyListeners();
    } else if (_currentPage == totalPages && _hasMore) {
      // We're at the end of filtered results but server has more
      await loadMoreProducts();

      // After loading more, check if we can go to next page
      if (_currentPage < totalPages) {
        _currentPage++;
        notifyListeners();
      }
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      // setMinPrice();
      // setMaxPrice();
      notifyListeners();
    }
  }

  // === UTILITY METHODS ===
  int get totalProductsCount => _allProducts.length;
  int get filteredProductsCount => _filteredProducts.length;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
