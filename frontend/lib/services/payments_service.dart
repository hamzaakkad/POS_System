import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payments_model.dart';

class FetchPaymentsService {
  final String baseUrl = 'http://127.0.0.1:5000/api';

  Future<List<PaymentsModel>> fetchPayments() async {
    final url = '$baseUrl/orders/payments';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      final List data = json['Payment records'];
      return data.map((e) => PaymentsModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load payment records: ${response.statusCode}, ${response.body}',
      );
    }
  }
}
