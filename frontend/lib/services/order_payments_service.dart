import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order_payments_model.dart';

class OrderPaymentsService {
  //allllll original
  //home made ;)
  final String baseUrl = 'http://localhost:5000/api';

  Future<List<OrderPaymentsModel>> fetchOrderPayments(int orderId) async {
    final url = '$baseUrl/orders/orderpayments/$orderId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      final List data = json['payment_records'] ?? [];
      debugPrint("Fetched payment records $data");
      return data.map((e) => OrderPaymentsModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load payment records: ${response.statusCode}, ${response.body}',
      );
    }
  }
}
