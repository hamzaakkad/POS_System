
class PaymentsModel {
  final int? id;
  final int? order_id;
  final dynamic order_price;
  final String? method;
  final int? money_left;

  PaymentsModel({
    this.id,
    this.order_id,
    this.order_price,
    this.method,
    this.money_left,
  });

  factory PaymentsModel.fromJson(Map<String, dynamic> json) {
    return PaymentsModel(
      id: json['id'],
      order_id: json['order_id'],
      order_price: json['order_price'],
      method: json['method'],
      money_left: json['money_left'],
    );
  }
}
