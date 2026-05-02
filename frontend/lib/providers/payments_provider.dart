import 'package:flutter/material.dart';
import 'package:pos_system/models/payments_model.dart';
import 'package:pos_system/pages/payment_page.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:pos_system/services/payments_service.dart';
import 'package:provider/provider.dart';

class PaymentsProvider extends ChangeNotifier {
  final FetchPaymentsService _service = FetchPaymentsService();

  List<PaymentsModel> _orders = [];
  bool _loading = false;
  String? _error;
  late int money_left;
  List<PaymentsModel> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchPayments() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _service.fetchPayments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // void selectPaymentMethod(String method) {
  //   // setState(() {
  //   // final ordersProvider = context.read<OrdersProvider>();
  //   PaymentPageState().selectedPaymentMethod = method;
  //   // if (method == 'card') {
  //   //   // PaymentPageState().amountController.text = PaymentPageState().amountToPay.toString();
  //   // }
  //   notifyListeners();
  //   // });
  // }
}
