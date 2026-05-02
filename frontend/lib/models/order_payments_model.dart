class OrderPaymentsModel {
  final dynamic id;
  final dynamic order_id;
  final dynamic price;

  OrderPaymentsModel({
    required this.id,
    required this.order_id,
    required this.price,
  });

  // Map<String, dynamic>.fromJson
  factory OrderPaymentsModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentsModel(
      id: json['id'],
      order_id: json['order_id'],
      price: json['price'],
    );
  }
}
