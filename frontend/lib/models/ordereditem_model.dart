class OrderedItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderedItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderedItem.fromJson(Map<String, dynamic> json) {
    return OrderedItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? 'Unknown Product',
      quantity: json['quantity'],
      // Ensure we handle the double/decimal correctly
      unitPrice: double.parse(json['unit_price'].toString()),
    );
  }

  double get subtotal => quantity * unitPrice;
}
