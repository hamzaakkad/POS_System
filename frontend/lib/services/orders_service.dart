import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import '../models/orders_model.dart';

// }

class FetchOrdersService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  Future<List<OrderModel>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      // final List data = jsonDecode(response.body);
      // return data.map((e) => PosModel.fromJson(e)).toList();
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List data = json['orders'];
      return data.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Orders');
    }
  }
}

class OrderService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  Future<Order> createOrder(List<Map<String, dynamic>> items) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'items': items}),
    );

    if (resp.statusCode != 201) {
      throw Exception('Failed to create order: ${resp.body}');
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    // my POST returns order_id and total — map into an Order stub
    return Order(
      id: body['order_id'] as int,
      total: (body['total'] is num)
          ? (body['total'] as num).toDouble()
          : double.parse('${body['total']}'),
      items:
          [], // server response doesn't include items after POST; fetch /orders/<id> if i need items
    );
  }

  Future<List<Order>> fetchOrders(int offset) async {
    if (offset <= 0) {
      offset = 0;
    }
    final resp = await http.get(
      Uri.parse('$baseUrl/orders?limit=20&offset=$offset'),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch orders: ${resp.body}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final ordersJson = body['orders'] as List<dynamic>;
    // debugPrint(body.toString());
    return ordersJson
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Order> fetchOrderById(int? id) async {
    final resp = await http.get(Uri.parse('$baseUrl/orders/$id'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch order: ${resp.body}');
    }
    return Order.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> deleteOrder(int? id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/orders/delete/$id'));
    if (resp.statusCode != 200) {
      throw Exception("Failed to delete order: ${resp.body}");
    } else {
      debugPrint("Order deleted successfully");
    }
  }

  Future payWithCash(
    BuildContext context,
    int? orderId,
    int? paidPrice,
  ) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/orders/cashpayment/$orderId/$paidPrice'),
    );
    if (resp.statusCode != 200) {
      throw Exception("failed to pay order: ${resp.body}");
    } else {
      debugPrint("Order Paid successfully");
      SnackbarWidget('Payment Succeded!', Colors.green, context);
    }
  }
}
