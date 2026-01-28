import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/categories_service.dart';

class ProductsProvider extends ChangeNotifier {
  final productService _service = productService();
  final productPageService _productPageService = productPageService();
  final FetchCategorizedProducts _fetchCategorizedProducts =
      FetchCategorizedProducts();
  final postProductService _postService = postProductService();
  final ArchiveProductService _archiveService = ArchiveProductService();
  final FetchCategoriesService _categoriesService = FetchCategoriesService();

  final List<productModel> _allProducts = [];
  final List<productPageModel> _allProductsPageProducts = [];

  final List<productModel> _filteredProducts = [];

  final List<productPageModel> _filteredProductsPageProducts = [];

  String _searchQuery = '';
  String _pageSearchQuery = '';
  int? _minPrice;
  int? _maxPrice;
  int? _lowStockThreshold;
  int? _categoryId;

  bool _loading = false;
  bool _pageLoading = false;
  bool _loadingMore = false;
  bool _pageLoadingMore = false;
  String? _error;

  bool _hasMore = true;
  bool _pageHasMore = true;
  int _currentPage = 1;
  int _pageCurrentPage = 1;

  final int _itemsPerPage = 20;
  bool? _sortAtoZ = false;
  bool? _sortZtoA = false;
  bool _inStock = false;
  bool _outOfStock = false;
  bool? _sortAtoZPage = false;
  bool? _sortZtoAPage = false;
  bool _inStockPage = false;
  bool _outOfStockPage = false;
  int? _minPricePage;
  int? _maxPricePage;

  bool get loading => _loading;
  bool get pageLoading => _pageLoading;
  bool get loadingMore => _loadingMore;
  bool get pageLoadingMore => _pageLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get pageHasMore => _pageHasMore;
  int get currentPage => _currentPage;
  int get pageCurrentPage => _pageCurrentPage;
  int get itemsPerPage => _itemsPerPage;
  int? get selectedCategoryId => _categoryId;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;
  bool? get sortAtoZ => _sortAtoZ;
  bool? get sortZtoA => _sortZtoA;
  bool get inStock => _inStock;
  bool get outOfStock => _outOfStock;
  bool? get sortAtoZPage => _sortAtoZPage;
  bool? get sortZtoAPage => _sortZtoAPage;
  bool get inStockPage => _inStockPage;
  bool get outOfStockPage => _outOfStockPage;
  int? get minPricePage => _minPricePage;
  int? get maxPricePage => _maxPricePage;

  int get totalPages {
    if (_filteredProducts.isEmpty) return 1;
    return (_filteredProducts.length / _itemsPerPage).ceil().clamp(1, 999);
  }

  int get pageTotalPages {
    if (_filteredProductsPageProducts.isEmpty) return 1;
    return (_filteredProductsPageProducts.length / _itemsPerPage).ceil().clamp(
      1,
      999,
    );
  }

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

  UnmodifiableListView<productPageModel> get productsPageProducts {
    final start = (_pageCurrentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (start >= _filteredProductsPageProducts.length) {
      return UnmodifiableListView([]);
    }

    final items = _filteredProductsPageProducts.sublist(
      start,
      end > _filteredProductsPageProducts.length
          ? _filteredProductsPageProducts.length
          : end,
    );

    return UnmodifiableListView(items);
  }

  UnmodifiableListView<productModel> get allFilteredProducts {
    return UnmodifiableListView(_filteredProducts);
  }

  Future<void> fetchProducts({
    String? searchQuery,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (_loadingMore || !_hasMore) return;
      _loadingMore = true;
    } else {
      _loading = true;
      _currentPage = 1;
      _allProducts.clear();
    }
    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }

    _error = null;
    notifyListeners();

    try {
      final fetched = await _service.fetchProducts(
        category: _categoryId,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        inStock: _inStock,
        outOfStock: _outOfStock,
        sort_ZtoA: _sortZtoA,
        sort_AtoZ: _sortAtoZ,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        loadMore: loadMore,
      );

      if (loadMore) {
        _allProducts.addAll(fetched);
      } else {
        _allProducts.clear();
        _allProducts.addAll(fetched);
      }

      _hasMore = _service.currentCursor != null;

      _applySearchAndFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProductsPageProducts() async {
    if (_pageLoadingMore || !_pageHasMore) return;
    _pageLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final newProducts = await _productPageService.fetchProducts(
        category: null,
        inStock: _inStockPage,
        outOfStock: _outOfStockPage,
        sort_ZtoA: _sortZtoAPage,
        sort_AtoZ: _sortAtoZPage,
        loadMore: true,
        searchQuery: _pageSearchQuery.isNotEmpty ? _pageSearchQuery : null,
        minPrice: _minPricePage,
        maxPrice: _maxPricePage,
      );

      for (var item in newProducts) {
        _allProductsPageProducts.add(productPageModel.fromProductModel(item));
      }

      _pageHasMore = _productPageService.currentCursor != null;

      _applyPageFilters();

      if (_productPageService.remainingCount == 0) {
        _pageHasMore = false;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _pageLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> nextPagePage() async {
    if (_pageCurrentPage < pageTotalPages) {
      _pageCurrentPage++;
      notifyListeners();
    } else if (_pageCurrentPage == pageTotalPages && _pageHasMore) {
      await loadMoreProductsPageProducts();

      if (_pageCurrentPage < pageTotalPages) {
        _pageCurrentPage++;
        notifyListeners();
      }
    }
  }

  Future<void> fetchProductsPageProducts({String? searchQuery}) async {
    _pageLoading = true;
    _error = null;
    _pageHasMore = true;
    _pageCurrentPage = 1;
    notifyListeners();

    try {
      _productPageService.currentCursor = null;

      final fetchedData = await _productPageService.fetchProducts(
        category: null,
        inStock: _inStockPage,
        outOfStock: _outOfStockPage,
        sort_ZtoA: _sortZtoAPage,
        sort_AtoZ: _sortAtoZPage,
        loadMore: false,
        searchQuery: searchQuery,
        minPrice: _minPricePage,
        maxPrice: _maxPricePage,
      );

      _allProductsPageProducts.clear();

      for (var item in fetchedData) {
        _allProductsPageProducts.add(productPageModel.fromProductModel(item));
      }

      _pageHasMore = _productPageService.currentCursor != null;
      _pageSearchQuery = searchQuery ?? '';

      _applyPageFilters();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching Products Page: $e');
    } finally {
      _pageLoading = false;
      notifyListeners();
    }
  }

  void _applyPageFilters() {
    List<productPageModel> result = List.from(_allProductsPageProducts);

    if (_pageSearchQuery.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(_pageSearchQuery.toLowerCase()),
          )
          .toList();
    }

    _filteredProductsPageProducts
      ..clear()
      ..addAll(result);

    if (_pageCurrentPage > pageTotalPages) {
      _pageCurrentPage = pageTotalPages > 0 ? pageTotalPages : 1;
    }

    notifyListeners();
  }

  Future<void> setMinPrice(int? minimumPrice) async {
    _minPrice = minimumPrice;
    _currentPage = 1;
    debugPrint("set minimum price method received: $minimumPrice");
    await fetchProducts();
  }

  Future<void> setMaxPrice(int? maximumPrice) async {
    _maxPrice = maximumPrice;
    _currentPage = 1;
    debugPrint("set MAXIMUM price method received: $maximumPrice");
    await fetchProducts();
  }

  // void setCategory(int? id) {
  //   _categoryId = id;
  //   _currentPage = 1;
  //   _searchQuery = '';
  //   _sortAtoZ = false;
  //   _sortZtoA = false;
  //   _inStock = false;
  //   _outOfStock = false;
  //   _minPrice = null;
  //   _maxPrice = null;
  //   fetchProducts();
  // }
  void setCategory(int? id) {
    _categoryId = id;
    _currentPage = 1;
    _searchQuery = '';
    _sortAtoZ = false;
    _sortZtoA = false;
    _inStock = false;
    _outOfStock = false;
    _minPrice = null;
    _maxPrice = null;
    fetchProducts();
  }

  resetPagination() {
    _currentPage = 1;
  }

  void resetPagePagination() {
    _pageCurrentPage = 1;
  }

  Future<void> loadMoreProducts() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    _error = null;
    notifyListeners();
    try {
      final newProducts = await _service.fetchProducts(
        category: _categoryId,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        inStock: _inStock,
        outOfStock: _outOfStock,
        sort_ZtoA: _sortZtoA,
        sort_AtoZ: _sortAtoZ,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        loadMore: true,
      );

      _allProducts.addAll(newProducts);
      _hasMore = _service.currentCursor != null;

      _applySearchAndFilters();
      if (_service.remainingCount == 0) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchProducts();
  Future<void> refreshCategories() => _categoriesService.fetchCategories();
  Future<void> refreshCategorizedProducts() => fetchProducts();

  Future<void> postProduct(productModel product) async {
    _loading = true;
    notifyListeners();
    try {
      await _postService.postProduct(product);
      await fetchProducts();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> archiveProduct(int id) async {
    try {
      await _archiveService.archiveProduct(id);

      _allProducts.removeWhere((p) => p.id == id);
      _filteredProducts.removeWhere((p) => p.id == id);

      _allProductsPageProducts.removeWhere((p) => p.id == id);
      _filteredProductsPageProducts.removeWhere((p) => p.id == id);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _currentPage = 1;
    fetchProducts();
  }

  void setInStockOnly(bool value) {
    _currentPage = 1;
    _inStock = value;
    _outOfStock = false;
    fetchProducts();
  }

  void setOutOfStockOnly(bool value) {
    _currentPage = 1;
    _outOfStock = value;
    _inStock = false;
    fetchProducts();
  }

  void setPageInStockOnly(bool value) {
    _inStockPage = value;
    _outOfStockPage = false;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void setPageOutOfStockOnly(bool value) {
    _outOfStockPage = value;
    _inStockPage = false;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void setPageSortByName(bool value) {
    _sortAtoZPage = value;
    _sortZtoAPage = false;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void setPageSortByNameDESC(bool value) {
    _sortZtoAPage = value;
    _sortAtoZPage = false;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void setPageMinPrice(int? value) {
    _minPricePage = value;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void setPageMaxPrice(int? value) {
    _maxPricePage = value;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void resetPageFilters() {
    _pageSearchQuery = '';
    _sortAtoZPage = false;
    _sortZtoAPage = false;
    _inStockPage = false;
    _outOfStockPage = false;
    _minPricePage = null;
    _maxPricePage = null;
    _pageCurrentPage = 1;
    fetchProductsPageProducts();
  }

  void setLowStockThreshold(int? value) {
    _currentPage = 1;
    _lowStockThreshold = value;
    _applySearchAndFilters();
  }

  void sortByPrice(bool ascending) {
    _currentPage = 1;
    _applySearchAndFilters();
  }

  void sortByName(bool ascending) {
    _currentPage = 1;
    _sortAtoZ = true;
    _sortZtoA = false;
    fetchProducts();
  }

  void sortByNameDESC(bool descending) {
    _currentPage = 1;
    _sortAtoZ = false;
    _sortZtoA = true;
    fetchProducts();
  }

  void resetFilters() {
    _currentPage = 1;
    _searchQuery = '';
    _minPrice = null;
    _maxPrice = null;
    _sortAtoZ = false;
    _sortZtoA = false;
    _inStock = false;
    _outOfStock = false;
    _categoryId = null;
    fetchProducts();
  }

  void _applySearchAndFilters() {
    Iterable<productModel> result = List.from(_allProducts);

    if (_searchQuery.isNotEmpty) {
      result = result.where(
        (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
      );
    }

    _filteredProducts.clear();
    _filteredProducts.addAll(result);

    if (_currentPage > totalPages) _currentPage = totalPages;

    notifyListeners();
  }

  Future<void> nextPage() async {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    } else if (_currentPage == totalPages && _hasMore) {
      await loadMoreProducts();
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

  void previousPagePage() {
    if (_pageCurrentPage > 1) {
      _pageCurrentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  int get totalProductsCount => _allProducts.length;
  int get filteredProductsCount => _filteredProducts.length;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
