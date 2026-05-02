import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class productService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  String? currentCursor;
  String? searchQuery;

  int? remainingCount;
  String? _currentCursor;

  Future<List<productModel>> fetchProducts({
    bool loadMore = false,
    String? searchQuery,
    int? minPrice,
    int? maxPrice,
    bool? sort_AtoZ = false,
    bool? sort_ZtoA = false,
    bool? inStock = false,
    bool? outOfStock = false,
    int? category,
  }) async {
    if (!loadMore) {
      _currentCursor = null;
    }

    final search = (searchQuery != null && searchQuery.isNotEmpty)
        ? '&search=$searchQuery'
        : '';

    final query = _currentCursor == null ? '' : '&cursor=$_currentCursor';
    final minPriceQuery = minPrice == null ? '' : '&min_price=$minPrice';
    final maxPriceQuery = maxPrice == null ? '' : '&max_price=$maxPrice';
    final sortAsc = sort_AtoZ == true ? '&sort_atoz=true' : '';
    final sortDesc = sort_ZtoA == true ? '&sort_ztoa=true' : '';
    final inStockOnly = inStock == true ? '&instock=1' : '';
    final outOfStockOnly = outOfStock == true ? '&outofstock=1' : '';
    final categoryId = category == null ? '' : '&category=$category';

    final url =
        '$baseUrl/products/paged?limit=20$query$search$minPriceQuery$maxPriceQuery$sortAsc$sortDesc$inStockOnly$outOfStockOnly$categoryId';

    debugPrint('Fetching products URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);

      if (remainingCount == 1 || remainingCount == 0) {
        currentCursor = null;
      } else {
        currentCursor = '0';
      }

      final List data = json['products'];
      _currentCursor = json['next_cursor']?.toString();
      remainingCount = json['remaining_count'];
      debugPrint(
        'Fetched ${data.length} products, next cursor: $_currentCursor, remaining count is: $remainingCount, and user searched for : $searchQuery, and minimum asked price is : $minPrice, and maximim asked price is : $maxPrice, and category id is: $categoryId',
      );

      return data.map((e) => productModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load products: ${response.statusCode}, ${response.body}',
      );
    }
  }

  bool get hasMore => _currentCursor != null;
}

class productPageService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  String? currentCursor;
  String? searchQuery;

  int? remainingCount;
  String? ccurrentCursor;

  Future<List<productModel>> fetchProducts({
    bool loadMore = false,
    String? searchQuery,
    int? minPrice,
    int? maxPrice,
    bool? sort_AtoZ = false,
    bool? sort_ZtoA = false,
    bool? inStock = false,
    bool? outOfStock = false,
    int? category,
  }) async {
    if (!loadMore) {
      currentCursor = null;
    }

    final search = (searchQuery != null && searchQuery.isNotEmpty)
        ? '&search=$searchQuery'
        : '';

    final query = currentCursor == null ? '' : '&cursor=$currentCursor';
    final minPriceQuery = minPrice == null ? '' : '&min_price=$minPrice';
    final maxPriceQuery = maxPrice == null ? '' : '&max_price=$maxPrice';
    final sortAsc = sort_AtoZ == true ? '&sort_atoz=true' : '';
    final sortDesc = sort_ZtoA == true ? '&sort_ztoa=true' : '';
    final inStockOnly = inStock == true ? '&instock=1' : '';
    final outOfStockOnly = outOfStock == true ? '&outofstock=1' : '';
    final categoryId = category == null ? '' : '&category=$category';

    final url =
        '$baseUrl/products/paged?limit=20$query$search$minPriceQuery$maxPriceQuery$sortAsc$sortDesc$inStockOnly$outOfStockOnly$categoryId';

    debugPrint('Fetching products page URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);

      if (remainingCount == 1 || remainingCount == 0) {
        currentCursor = null;
      } else {
        currentCursor = '0';
      }

      final List data = json['products'];
      currentCursor = json['next_cursor']?.toString();
      remainingCount = json['remaining_count'];
      debugPrint(
        'Fetched ${data.length} products, next cursor: $currentCursor, remaining count is: $remainingCount, and user searched for : $searchQuery, and minimum asked price is : $minPrice, and maximim asked price is : $maxPrice, and category id is: $categoryId',
      );

      return data.map((e) => productModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  bool get hasMore => currentCursor != null;
}

class FetchCategorizedProducts {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  Future<List<productModel>> fetchProducts({
    bool loadMore = false,
    String? searchQuery,
    int? minPrice,
    int? maxPrice,
    bool? sort_AtoZ = false,
    bool? sort_ZtoA = false,
    bool? inStock = false,
    bool? outOfStock = false,
    int? category,
  }) async {
    final search = (searchQuery != null && searchQuery.isNotEmpty)
        ? '&search=$searchQuery'
        : '';
    final minPriceQuery = minPrice == null ? '' : '&min_price=$minPrice';
    final maxPriceQuery = maxPrice == null ? '' : '&max_price=$maxPrice';
    final sortAsc = sort_AtoZ == true ? '&sort_atoz=true' : '';
    final sortDesc = sort_ZtoA == true ? '&sort_ztoa=true' : '';
    final inStockOnly = inStock == true ? '&instock=1' : '';
    final outOfStockOnly = outOfStock == true ? '&outofstock=1' : '';

    final url =
        '$baseUrl/categories/$category/products?limit=20$search$minPriceQuery$maxPriceQuery$sortAsc$sortDesc$inStockOnly$outOfStockOnly';

    debugPrint('Fetching categorized products URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String?, dynamic> json = jsonDecode(response.body);
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      final List data = json['products'] ?? [];

      return data.map((e) => productModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}

class UpdateProductService {
  final String baseUrl = 'http://localhost:5000/api';
  Future<void> updateProduct(Map<String, dynamic> data, int productId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print("Product updated successfully");
    } else {
      print(
        "Failed to update product: ${response.statusCode} ${response.body}",
      );
    }
  }
}

class postProductService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  Future<void> postProductRaw(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create product: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<String> uploadImage(File file) async {
    // final uri = Uri.parse('$baseUrl/uploads');
    //https://api.cloudinary.com/v1_1/df3uhshzy/image/upload?upload_preset=POS-SYSTEM%20Images
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/df3uhshzy/image/upload?upload_preset=POS-SYSTEM%20Images',
    );
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    // debugPrint("Image upload failed: ${response.statusCode} ${response.body}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      //  debugPrint(body['url']);
      return body['url'] as String;
    } else {
      throw Exception(
        "Image upload failed: ${response.statusCode} ${response.body}",
      );
    }
  }

  Future<void> postProduct(productModel product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },

      body: jsonEncode(<String, dynamic>{
        "name": product.name,
        "price": product.price,
        "storage_quantity": product.stock,
        "category_ids": product.category_id != null
            ? [product.category_id]
            : [],
      }),
    );
    if (response.statusCode == 201) {
      print("Recieved 201 from post Product Service line 97");
    } else {
      print(
        "Error while trying to post the response post Product Service: ${response.statusCode} / line 100",
      );
    }
  }
}

class ArchiveProductService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  Future<void> archiveProduct(int productId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/archive/$productId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Server returned status: ${response.statusCode}');
    }
  }
}
