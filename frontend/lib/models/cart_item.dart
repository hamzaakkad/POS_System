import 'product_model.dart';

class CartItem {
  final productModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// total price for this cart line
  double get total => product.price * quantity;

  /// safe copy for orders snapshot
  CartItem copy() {
    return CartItem(product: product, quantity: quantity);
  }
}
