import 'package:flutter/material.dart';
import 'package:pos_system/models/order_payments_model.dart';
import 'package:pos_system/models/orders_model.dart';
import 'package:pos_system/providers/cart_provider.dart';
import 'package:pos_system/providers/payments_provider.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:pos_system/services/order_payments_service.dart';
import 'package:pos_system/services/orders_service.dart';
import 'package:provider/provider.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderService _service = OrderService();

  List<Order> _orders = [];
  bool isLoading = false;
  String? _error;
  int _currentOffset = 0;
  final int _itemsPerPage = 20;
  bool _hasMore = true;

  List<Order> get orders => _orders;
  // bool get isLoading => isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Order? _order;
  List<OrderPaymentsModel> _paymentHistory = [];

  Order? get order => _order;
  List<OrderPaymentsModel> get paymentHistory => _paymentHistory;

  // ========== COMPUTED PROPERTIES FOR SINGLE ORDER PAGE ==========
  double get totalPaid {
    if (_paymentHistory.isEmpty) return 0;
    return _paymentHistory.fold(0.0, (sum, p) {
      final price = p.price is String
          ? double.parse(p.price as String)
          : (p.price as num).toDouble();
      return sum + price;
    });
  }

  double get remaining {
    if (_order == null) return 0;
    return _order!.total - totalPaid;
  }

  String get paymentStatusText {
    if (_order == null) return '';
    if (remaining <= 0) return 'Paid';
    if (totalPaid > 0) return 'Partially Paid';
    return 'Pending';
  }

  Color get paymentStatusColor {
    if (_order == null) return Colors.grey;
    if (remaining <= 0) return Colors.green;
    if (totalPaid > 0) return Colors.orange;
    return Colors.red;
  }

  String get formattedOrderDate {
    if (_order == null || _order!.createdAt == null) return 'Unknown date';
    final date = _order!.createdAt!;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ========== EXISTING METHODS ==========
  Future<void> loadOrders() async {
    // isLoading = true;
    isLoading = false;

    if (_orders.isNotEmpty) {
      // isLoading = false;

      return;
    }
    await refreshOrders();
    // isLoading = false;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    _currentOffset = 0;
    _hasMore = true;

    _orders = [];

    _error = null;
    // print("object");

    await fetchNextBatch();
    // isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNextBatch() async {
    if (isLoading || !_hasMore) return;

    isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Order> newOrders = await _service.fetchOrders(_currentOffset);

      if (newOrders.isEmpty) {
        _hasMore = false;
      } else {
        _orders.addAll(newOrders);
        _currentOffset += _itemsPerPage;

        if (newOrders.length < _itemsPerPage) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(int? id) async {
    try {
      await _service.deleteOrder(id);
      _orders.removeWhere((order) => order.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> payWithCash(
    BuildContext context,
    int? orderId,
    double amount,
  ) async {
    try {
      await _service.payWithCash(context, orderId, amount.toInt());
      await refreshOrders();
    } catch (e) {
      rethrow;
    }
  }

  void handleCheckout(BuildContext context) async {
    // 1. Capture the items before the async call
    final cartProvider = context.read<CartProvider>();
    final itemsForApi = cartProvider.cart.values
        .map(
          (item) => {"product_id": item.product.id, "quantity": item.quantity},
        )
        .toList();

    try {
      final result = await OrderService().createOrder(itemsForApi);

      // 2. CHECK MOUNTED before using context again
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order #${result.id} placed! Total: \$${result.total}"),
          backgroundColor: Colors.green,
        ),
      );

      // 3. Clear and Refresh
      await context.read<ProductsProvider>().refresh();
      if (!context.mounted) return; // Check again after the second await

      context.read<CartProvider>().clearCart();

      // 4. Navigate
      Navigator.pushNamed(context, '/payment', arguments: result.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> fetchOrderDetails(dynamic orderId) async {
    isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        OrderService().fetchOrderById(orderId),
        OrderPaymentsService().fetchOrderPayments(orderId),
      ]);

      _order = results[0] as Order;
      _paymentHistory = results[1] as List<OrderPaymentsModel>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isPartialPayment = false;
  int amountToPay = 0;

  Future<void> fetchOrder(
    BuildContext context,
    dynamic orderId,
    TextEditingController amountController,
  ) async {
    try {
      final order = await OrderService().fetchOrderById(orderId);
      await context.read<PaymentsProvider>().fetchPayments();
      final payments = context.read<PaymentsProvider>().orders;
      final payment = payments.where((p) => p.order_id == orderId).firstOrNull;
      //all this broke my brain .-.
      _order = order;
      isPartialPayment =
          payment != null &&
          payment.money_left != null &&
          payment.money_left! > 0;
      if (isPartialPayment) {
        amountToPay = payment!.money_left!;
      } else {
        amountToPay = _order!.computedTotal.toInt() + 1;
      }
      // Do NOT set controller text here - let UI handle initial value
      notifyListeners();
    } catch (e) {
      // Handle error via snackbar
      SnackbarWidget('Failed to load order: $e', Colors.red, context);
    }
  }

  int changeAmount = 0;

  void calculateChange(TextEditingController amountController) {
    final amountPaid = int.tryParse(amountController.text) ?? 0;
    final subtotal = amountToPay;
    final finalTotal = subtotal;
    changeAmount = amountPaid - finalTotal;
    notifyListeners();
  }

  bool isProcessing = false;
  String selectedPaymentMethod = 'cash';

  void updatePaymentMethod(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void processPayment(
    BuildContext context,
    TextEditingController amountController,
    dynamic orderId,
  ) async {
    if (isProcessing || _order == null) return;

    isProcessing = true;
    notifyListeners();

    final amountPaid = int.tryParse(amountController.text) ?? 0;
    final finalTotal = amountToPay;

    try {
      if (selectedPaymentMethod == 'cash') {
        await payWithCash(context, orderId, amountPaid.toDouble());
      }

      isProcessing = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pop(context, {
          'success': true,
          'amountPaid': amountPaid,
          'paymentMethod': selectedPaymentMethod,
          'change': changeAmount,
        });
      }
    } catch (e) {
      isProcessing = false;
      notifyListeners();
      if (context.mounted) {
        SnackbarWidget('Payment failed: $e', Colors.red, context);
      }
    }
  }
}
