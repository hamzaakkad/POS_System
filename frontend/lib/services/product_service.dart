import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../pages/pos_dashboard.dart';

class productService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  // im testing 127 because its my ip address localhost
  // then i might test 0.0.0.0 or localhost if this didnt work
  String? currentCursor;
  String? searchQuery;

  //dynamic response;
  int? remainingCount;
  String? _currentCursor = null;

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
    // int? remaining_count,
  }) async {
    if (!loadMore) {
      _currentCursor = null; // Reset for first page
    }

    final search = (searchQuery != null && searchQuery.isNotEmpty)
        ? '&search=$searchQuery'
        : (this.searchQuery != null && this.searchQuery!.isNotEmpty)
        ? '&search=${this.searchQuery}'
        : '';

    final query = _currentCursor == null ? '' : '&cursor=$_currentCursor';
    //testing the min price route
    final minPriceQuery = minPrice == null ? '' : '&min_price=$minPrice';
    final maxPriceQuery = maxPrice == null ? '' : '&max_price=$maxPrice';
    final sort_ASC = sort_AtoZ == false ? '' : '&sort_atoz=true';
    final sort_DESC = sort_ZtoA == false ? '' : '&sort_ztoa=true';
    final inStockOnly = inStock == false ? '' : '&instock=0';
    final outOfStockOnly = outOfStock == false ? '' : '&outofstock=0';
    final category_id = category == null ? '' : '&category=$category';

    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/paged?limit=20$query$search$minPriceQuery$maxPriceQuery$sort_ASC$sort_DESC$inStockOnly$outOfStockOnly$category_id',
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);

      // to fix the ghosting products so they dont keep on appearing again and again
      if (remainingCount == 1 || remainingCount == 0) {
        // i put 1 because of an annoying ghosting bug new bug remove it and see if u want after the last page
        //_currentCursor = null;
        currentCursor = null;
        //hasMore = false;
      } else {
        currentCursor = '0';
      } // it worksssssssssssssssssssssss :)))))))))))))))))))))

      final List data = json['products'];
      _currentCursor = json['next_cursor']?.toString();
      remainingCount = json['remaining_count'];
      debugPrint(
        'Fetched ${data.length} products, next cursor: $_currentCursor, remaining count is: $remainingCount, and user searched for : $searchQuery, and minimum asked price is : $minPrice, and maximim asked price is : $maxPrice, and category id is: $category_id',
      );

      return data.map((e) => productModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  bool get hasMore => _currentCursor != null;
}
// Future<List<productModel>> fetchProducts(int? cursor) async {
//   final query = cursor == null ? '' : 'cursor=$cursor';
//   final response = await http.get(
//     Uri.parse('$baseUrl/products/paged?limit=20&$query'),
//   );

//   if (response.statusCode == 200) {
//     Map<String, dynamic> json = jsonDecode(response.body);
//     final List data = json['products'];
//     debugPrint(data.toString());

//     // Update cursor
//     currentCursor = json['next_cursor'];
//     debugPrint('Fetch products cursor: $currentCursor');

//     return data.map((e) => productModel.fromJson(e)).toList();
//   } else {
//     throw Exception('Failed to load products');
//   }
// }

// Future<List<productModel>> onLoadMorePressed() async {
//   final query = currentCursor == null ? '' : 'cursor=$currentCursor';
//   final response = await http.get(
//     Uri.parse('$baseUrl/products/paged?limit=20&$query'),
//   );

//   if (response.statusCode == 200) {
//     Map<String, dynamic> json = jsonDecode(response.body);
//     final List data = json['products'];
//     debugPrint(data.toString());

//     // FIX: You need to update the cursor here too!
//     currentCursor = json['next_cursor']; // This line was missing
//     debugPrint('Load more cursor: $currentCursor');

//     return data.map((e) => productModel.fromJson(e)).toList();
//   } else {
//     throw Exception('Failed to load products');
//   }
// }

class postProductService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  // for testing purposes
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
    final uri = Uri.parse('$baseUrl/uploads');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['url']
          as String; // this little one returns a path like the ones ive returned in the backend testing baseurl/uploads/products/<file>
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

      //Direct map used as the body
      body: jsonEncode(<String, dynamic>{
        "name": "${product.name}",
        "price": product.price,
        "storage_quantity": product.stock,
        "category_id": product.category_id,
      }),

      // body: jsonEncode(product.toJson()),
      //flutter pub run build_runner watch --delete-conflicting-outputs
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

// making the paginated products service its for testing the pagination server side

// class PaginatedProductService {
//   final String baseUrl = 'http://127.0.0.1:5000/api';

//   Future<ProductResponse> fetchPaginatedProducts({
//     int? cursor,
//     int limit = 20,
//   }) async {
//     // building the query parameters
//     final Map<String, String> queryParams = {'limit': limit.toString()};
//     // now were only adding cursor if its not null
//     if (cursor != null) {
//       queryParams['cursor'] = cursor.toString();
//     }
//     final uri = Uri.parse(
//       '$baseUrl/products/paged',
//     ).replace(queryParameters: queryParams);
//     final response = await http.get(uri);

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> json = jsonDecode(response.body);
//       return ProductResponse.fromJson(json);
//     } else {
//       throw Exception(
//         "Failed to load paginated products this error was triggered from the product service file : ${response.body} and this is the status code ${response.statusCode}",
//       );
//     }
//   }
// }
