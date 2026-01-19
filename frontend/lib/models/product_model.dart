class productModel {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;
  final int? category_id;

  productModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.category_id,
  });

  factory productModel.fromJson(Map<String, dynamic> json) {
    return productModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: json['storage_quantity'] ?? 0,
      imageUrl: json['image_url']?.toString(),
      category_id: json['category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'storage_quantity': stock,
      'image_url': imageUrl,
      'category_id': category_id,
    };
  }
}
// for testing the pagination
// class ProductResponse {
//   final List<dynamic> products;
//   final int count;
//   final int? nextCursor;

//   ProductResponse({
//     required this.products,
//     required this.count,
//     this.nextCursor,
//   });

//   factory ProductResponse.fromJson(Map<String, dynamic> json) {
//     return ProductResponse(
//       products: json['products'],
//       count: json['count'],
//       nextCursor: json['next_cursor'],
//     );
//   }
// }

class ResponseModel {
  final int? nextCursor;
  final int? remaining_count;

  ResponseModel({this.nextCursor, this.remaining_count});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      nextCursor: json['next_cursor'],
      remaining_count: json['remaining_count'],
    );
  }
}

// class Product {
//   final int id;
//   final String name;
//   final double price;
//   final int stock;
//   final String? imageUrl;

//   product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.stock,
//     this.imageUrl,
//   });
// }

// class Response {
//   final List<dynamic> products;
//   final int count;
//   final int? nextCursor;

//   Response({
//     required this.products,
//     required this.count,
//     this.nextCursor,
//   });
// }
