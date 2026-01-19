import 'package:pos_system/models/cart_item.dart';
import 'package:pos_system/models/product_model.dart';
import 'package:flutter/material.dart';

//states
//late Future<List<productModel>> _productsFuture;

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _cart = {};

  Map<int, CartItem> get cart => _cart;
  void addToCart(productModel product) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id]!.quantity++;
    } else {
      _cart[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    final item = _cart[productId];
    if (item == null) return;

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cart.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
