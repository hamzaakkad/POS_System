import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/orders_model.dart';
import '../models/ordereditem_model.dart';

//
// class ordersService {
//   final String baseUrl = 'http://127.0.0.1:5000/api';
//   // im testing 127 because its my ip address localhost
//   // then i might test 0.0.0.0 or localhost if this didnt work
//
//   Future<List<ordersModel>> postOrders() async {
//     final ordersPost = await http.post(Uri.parse('$baseUrl/orders'));
//
//     print('STATUS: ${ordersPost.statusCode}');
//     print("BODY: ${ordersPost.body}");
//     //ik dont invoke print statements in the final product but im still beta testing
//
//     if (ordersPost.statusCode == 201) {
//       final Map<String, dynamic> json = jsonDecode(ordersPost.body);
//       final List data = json['orders'];
//       return data.map((e) => ordersModel.fromJson(e)).toList();
//     } else {
//       throw Exception("faild to post order");
//     }
//   }
// }

class FetchOrdersService {
  final String baseUrl = 'http://127.0.0.1:5000/api';
  // im testing 127 because its my ip address localhost
  // then i might test 0.0.0.0 or localhost if this didnt work

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

// class OrderService {
//   final String baseUrl = "http://127.0.0.1:5000/api";

//   // 1. FETCH: Get details of a specific order (Receipt view)
//   Future<OrderModel> fetchOrderDetails(int orderId) async {
//     final response = await http.get(Uri.parse('$baseUrl/orders/$orderId'));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       return OrderModel.fromJson(data);
//     } else {
//       throw Exception('Failed to load order #$orderId');
//     }
//   }

//   // 2. This sends my Flutter cart to the Flask 'Snapshot' route
//   Future<Map<String, dynamic>> createOrder(
//     List<Map<String, dynamic>> items,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/orders'),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({"items": items}),
//       );

//       if (response.statusCode == 201) {
//         // Returns {"message": "Checkout complete", "order_id": 10, "total": 300.0} from my test

//         return json.decode(response.body);
//       } else {
//         final errorBody = json.decode(response.body);
//         throw Exception(errorBody['error'] ?? 'Failed to create order');
//       }
//     } catch (e) {
//       throw Exception('Network Error: $e');
//     }
//   }
// }

// class OrdersService {
//   final String baseUrl = 'http://127.0.0.1:5000/api';

// }

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

  Future<List<Order>> fetchOrders() async {
    final resp = await http.get(Uri.parse('$baseUrl/orders'));
    if (resp.statusCode != 200)
      throw Exception('Failed to fetch orders: ${resp.body}');
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final ordersJson = body['orders'] as List<dynamic>;
    return ordersJson
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Order> fetchOrderById(int id) async {
    final resp = await http.get(Uri.parse('$baseUrl/orders/$id'));
    if (resp.statusCode != 200)
      throw Exception('Failed to fetch order: ${resp.body}');
    return Order.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> deleteOrder(int id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/orders/delete/$id'));
    if (resp.statusCode != 200) {
      throw Exception("Failed to delete order: ${resp.body}");
    } else {
      debugPrint("Order deleted successfully");
    }
  }
}

// -- Orders table
// CREATE TABLE orders (
//     id INT PRIMARY KEY AUTO_INCREMENT,
//     total_price DECIMAL(10, 2),
//     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
// );
