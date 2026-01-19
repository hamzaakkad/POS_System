import 'dart:io' show HttpDate;

// class ordersModel {
//   final int id;
//   final double totalPrice;
//   //haven't emplemented created_at yet nor updated at yet
//
//   ordersModel({
//     required this.id,
//     required this.totalPrice,
//   });
//
//   factory ordersModel.fromJson(Map<String, dynamic> json) {
//     return ordersModel(
//       id: json['id'], //from my variables
//       totalPrice: double.parse(json['total_price'].toString()), //from my variables
//     );
//   }
//
// }

class OrderModel {
  final int id;
  final double totalPrice;
  final DateTime? createdAt;
  final List<OrderedItem> items;

  OrderModel({
    required this.id,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });

  // helper to parse multiple common date formats so no issue arises
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString();

    //imma Try ISO-8601 first as it is the most common format
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // if it didnt work imma try HTTP-date / RFC1123 formats (e.g. 'Sat, 27 Dec 2025 08:09:50 GMT') i got this from the internet i didnt know what that was
    try {
      return HttpDate.parse(s);
    } catch (_) {}

    //As a last resort, return null so caller can handle absence and never crash and imma handle the ui so it shows '-' when date is null
    return null;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse the list of items from the JSON array
    var list = json['items'] as List? ?? [];
    List<OrderedItem> itemsList = list
        .map((i) => OrderedItem.fromJson(i))
        .toList();

    return OrderModel(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: _parseDate(json['created_at']),
      items: itemsList,
    );
  }
}

class OrderedItem {
  final int? id;
  final int orderId;
  final int productId;
  final String? productName;
  int quantity;
  final double unitPrice;

  OrderedItem({
    this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
  });
  double get total => quantity * unitPrice;

  factory OrderedItem.fromJson(Map<String, dynamic> json) {
    return OrderedItem(
      id: json['id'] as int?,
      orderId: json['order_id'] is int
          ? json['order_id'] as int
          : int.parse('${json['order_id']}'),
      productId: json['product_id'] is int
          ? json['product_id'] as int
          : int.parse('${json['product_id']}'),
      productName: json['product_name'] as String?,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.parse('${json['quantity']}'),
      unitPrice: (json['unit_price'] is num)
          ? (json['unit_price'] as num).toDouble()
          : double.parse('${json['unit_price']}'),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'order_id': orderId,
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
  };

  OrderedItem copy() => OrderedItem(
    id: id,
    orderId: orderId,
    productId: productId,
    productName: productName,
    quantity: quantity,
    unitPrice: unitPrice,
  );
}

class Order {
  final int id;
  final double total;
  final String? status;
  final DateTime? createdAt;
  final List<OrderedItem> items;

  Order({
    required this.id,
    required this.total,
    this.status,
    this.createdAt,
    List<OrderedItem>? items,
  }) : items = items ?? [];

  int get itemsCount => items.fold(0, (s, i) => s + i.quantity);
  double get computedTotal => items.fold(0.0, (s, i) => s + i.total);

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>?;
    // `total` or `total_price`. like that it wouild  Accept both and never crashes again im lazy to go and see what the backend sends thats a faster approch.
    final totalVal = json['total'] ?? json['total_price'];

    final createdAtVal = json['created_at'];
    final parsedCreatedAt = OrderModel._parseDate(createdAtVal);

    return Order(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      total: (totalVal is num)
          ? (totalVal as num).toDouble()
          : double.parse('${totalVal ?? 0}'),
      status: json['status'] as String?,
      createdAt: parsedCreatedAt,
      items: itemsJson != null
          ? itemsJson
                .map((e) => OrderedItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'total': total,
    if (status != null) 'status': status,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/* // old one
-- Orders table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    total_price DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/
