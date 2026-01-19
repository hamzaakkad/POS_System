import 'package:flutter/material.dart';
import 'package:pos_system/services/orders_service.dart';
import '../models/orders_model.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderService _service = OrderService();

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _service.fetchOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(List<Map<String, dynamic>> items) async {
    final order = await _service.createOrder(items);
    await fetchOrders();

    //option b push order into list
    // _orders.insert(0, order);
    // notifyListeners();
    return;
  }

  // Delete order function all it took me to make a delete function was 5 minutes smh(because im focused) and listening to Dance with the devil instrumental on repeat in the backend and in the front end provider and service and command in the backend Cool
  // update it took me around 20 minutes because i had to debug why it wasnt working at first and changed everything about orders to providers
  Future<void> deleteOrder(int id) async {
    try {
      await _service.deleteOrder(id);
      _orders.removeWhere((order) => order.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
