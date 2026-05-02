import 'package:flutter/material.dart';
import 'package:pos_system/models/order_payments_model.dart';
import 'package:pos_system/models/orders_model.dart';
import 'package:pos_system/pages/payment_page.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';
import 'package:provider/provider.dart';

class SingleOrderPage extends StatefulWidget {
  final int orderId;
  const SingleOrderPage({super.key, required this.orderId});

  @override
  State<SingleOrderPage> createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  @override
  void initState() {
    super.initState();
    // Trigger data fetch when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final ordersProvider = context.watch<OrdersProvider>();

    final isLoading = ordersProvider.isLoading;
    final error = ordersProvider.error;
    final order = ordersProvider.order;
    final paymentHistory = ordersProvider.paymentHistory;

    // Computed values come directly from provider finally
    final totalPaid = ordersProvider.totalPaid;
    final remaining = ordersProvider.remaining;
    final paymentStatusText = ordersProvider.paymentStatusText;
    final paymentStatusColor = ordersProvider.paymentStatusColor;
    final formattedDate = ordersProvider.formattedOrderDate;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ORDER #${widget.orderId}',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
              ),
            )
          : error != null
              ? _ErrorView(error: error, onRetry: () => ordersProvider.fetchOrderDetails(widget.orderId))
              : order == null
                  ? _NotFoundView()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          _buildHeader(order, paymentStatusText, paymentStatusColor, formattedDate, isDark),
                          const SizedBox(height: 32),

                          // Order Items
                          _buildOrderItems(order, isDark),
                          const SizedBox(height: 32),

                          // Payment Status
                          _buildPaymentStatus(order, totalPaid, remaining, paymentStatusText, paymentStatusColor, isDark),
                          const SizedBox(height: 32),

                          // Payment History
                          if (paymentHistory.isNotEmpty) ...[
                            _buildPaymentHistory(paymentHistory, totalPaid, isDark),
                            const SizedBox(height: 32),
                          ],

                          // Payment Actions (if needed)
                          if (order.order_status == 'Pending' || remaining > 0)
                            _buildPaymentActions(context, order.id!, remaining, isDark, ordersProvider),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader(Order order, String statusText, Color statusColor, String date, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderSubtle : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: isDark ? AppColors.darkTextMuted : Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(date, style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: isDark ? AppColors.darkTextMuted : Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Total: \$${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (order.order_payment_method != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payment, size: 18, color: isDark ? AppColors.darkTextMuted : Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Payment Method: ${order.order_payment_method}',
                  style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER ITEMS',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderSubtle : Colors.grey.shade300),
          ),
          child: Column(
            children: order.items.map((item) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: isDark ? AppColors.borderSubtle : Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName ?? 'Product',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${item.unitPrice.toStringAsFixed(2)} each',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'x${item.quantity}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatus(Order order, double totalPaid, double remaining, String statusText, Color statusColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT STATUS',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderSubtle : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14)),
                  Text('\$${order.total.toStringAsFixed(2)}', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount Paid', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14)),
                  Text('\$${totalPaid.toStringAsFixed(2)}', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              if (remaining > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remaining', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14)),
                    Text('\$${remaining.toStringAsFixed(2)}', style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(List<OrderPaymentsModel> paymentHistory, double totalPaid, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT HISTORY',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderSubtle : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgPrimary.withOpacity(0.5) : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.borderSubtle : Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('Payment ID', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13))),
                    Expanded(flex: 2, child: Text('Amount', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13))),
                    Expanded(flex: 2, child: Text('Order ID', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
              // Items
              ...paymentHistory.map((payment) {
                final price = payment.price is String ? double.parse(payment.price) : payment.price.toDouble();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? AppColors.borderSubtle : Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('#${payment.id}', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, fontWeight: FontWeight.w500, fontSize: 14))),
                      Expanded(flex: 2, child: Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14))),
                      Expanded(flex: 2, child: Text('#${payment.order_id}', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14))),
                    ],
                  ),
                );
              }),
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgPrimary.withOpacity(0.3) : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Paid:', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('\$${totalPaid.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentActions(BuildContext context, int orderId, double remaining, bool isDark, OrdersProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT ACTIONS',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderSubtle : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete Payment', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text('Choose a payment method to complete this order.', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700, fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PaymentPage(orderId: orderId)),
                        ).then((_) {
                          provider.fetchOrderDetails(orderId);
                        });
                      },
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: Text(remaining > 0 ? 'Complete Payment' : 'Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Separate small error/not found widgets (still UI-only) stuff
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Retry', style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, color: isDark ? AppColors.darkTextMuted : Colors.grey.shade300, size: 60),
          const SizedBox(height: 16),
          Text('Order not found', style: TextStyle(color: isDark ? AppColors.darkTextMuted : Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}