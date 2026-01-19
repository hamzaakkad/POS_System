import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../services/orders_service.dart';
import '../models/orders_model.dart';
import '../reusable widgets/AppColors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final Set<int> _expandedOrders = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  Future<void> _refresh() async {
    await context.read<OrdersProvider>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;//imma keep it for later flexibal resizing options

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          'ORDERS',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: screenWidth > 800 ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Row(
                          children: [
                            // Theme toggle button to match dashboard
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextPrimary,
                              ),
                              onPressed: () =>
                                  context.read<ThemeProvider>().toggleTheme(),
                            ),
                            SizedBox(width: screenWidth > 800 ? 12 : 8),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBgElevated
                                    : AppColors.lightBgSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderSubtle
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextPrimary,
                                ),
                                onPressed: _refresh,
                                tooltip: 'Refresh',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// ORDERS TABLE
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgElevated
                              : AppColors.lightBgElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderSubtle
                                : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.4 : 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _tableHeader(screenWidth, isDark),
                            Container(
                              height: 1,
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Consumer<OrdersProvider>(
                                builder: (context, ordersProvider, _) {
                                  if (ordersProvider.loading) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: isDark
                                            ? AppColors.darkButtonsPrimary
                                            : AppColors.accentBlue,
                                      ),
                                    );
                                  }
                                  if (ordersProvider.error != null) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Error: ${ordersProvider.error}',
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors
                                                          .darkTextSecondary
                                                    : Colors.red,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: _refresh,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDark
                                                    ? AppColors
                                                          .darkButtonsPrimary
                                                    : AppColors.accentBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: Text(
                                                'Retry',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? AppColors
                                                            .darkTextPrimary
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  final orders = ordersProvider.orders;
                                  if (orders.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_long_outlined,
                                            color: isDark
                                                ? AppColors.darkTextMuted
                                                : Colors.grey.shade300,
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No orders yet',
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColors.darkTextMuted
                                                  : Colors.grey,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final o = orders[index];
                                      final expanded = _expandedOrders.contains(
                                        o.id,
                                      );
                                      return Column(
                                        children: [
                                          _orderRow(
                                            o,
                                            expanded,
                                            screenWidth,
                                            context,
                                          ),
                                          if (expanded)
                                            _orderDetails(
                                              o,
                                              screenWidth,
                                              isDark,
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tableHeader(double screenWidth, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _HeaderText(
                  'ORDER NUMBER',
                  flex: 3,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                if (screenWidth > 600)
                  _HeaderText(
                    'ID',
                    flex: 1,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
                _HeaderText(
                  'TOTAL',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                if (screenWidth > 800)
                  _HeaderText(
                    'CREATED AT',
                    flex: 4,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
                if (screenWidth <= 800 && screenWidth > 600)
                  _HeaderText(
                    'DATE',
                    flex: 3,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
          SizedBox(width: screenWidth > 800 ? 120 : 100),
        ],
      ),
    );
  }

  Widget _orderRow(
    Order order,
    bool expanded,
    double screenWidth,
    BuildContext context,
  ) {
    final isDark = context.watch<ThemeProvider>().isDark;

    final created = order.createdAt;
    final createdText = created != null
        ? screenWidth > 800
              ? '${created.day}/${created.month}/${created.year} ${created.hour}:${created.minute.toString().padLeft(2, '0')}'
              : '${created.day}/${created.month}/${created.year}'
        : '-';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderSubtle : Colors.grey.shade200,
          ),
        ),
        color: expanded
            ? (isDark
                  ? AppColors.darkButtonsPrimary.withOpacity(0.1)
                  : AppColors.accentBlue.withOpacity(0.08))
            : isDark
            ? AppColors.darkBgElevated
            : AppColors.lightBgElevated,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _RowText(
                  'Order #${order.id}',
                  flex: 3,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                if (screenWidth > 600)
                  _RowText(
                    '${order.id}',
                    flex: 1,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
                _RowText(
                  '\$${order.total.toStringAsFixed(2)}',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                  isBold: true,
                  color: isDark
                      ? AppColors.darkButtonsPrimary
                      : AppColors.accentBlue,
                ),
                if (screenWidth > 800)
                  _RowText(
                    createdText,
                    flex: 4,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
                if (screenWidth <= 800 && screenWidth > 600)
                  _RowText(
                    createdText,
                    flex: 3,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
          SizedBox(width: screenWidth > 800 ? 12 : 8),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.danger.withOpacity(0.1)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? AppColors.danger.withOpacity(0.3)
                    : Colors.red.shade200,
              ),
            ),
            child: IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: isDark
                          ? AppColors.darkBgElevated
                          : AppColors.lightBgElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delete Order?',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Are you sure you want to delete this order?\nThis action cannot be undone.",
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: isDark
                                          ? AppColors.borderSubtle
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    final ordersProvider = context
                                        .read<OrdersProvider>();
                                    await ordersProvider.deleteOrder(order.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Order #${order.id} deleted',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: Icon(
                Icons.delete_outline,
                color: isDark ? AppColors.danger : Colors.red.shade600,
                size: screenWidth > 800 ? 22 : 18,
              ),
              tooltip: 'Delete Order',
            ),
          ),
          SizedBox(width: screenWidth > 800 ? 12 : 8),
          Container(
            decoration: BoxDecoration(
              color: expanded
                  ? (isDark
                        ? AppColors.darkButtonsPrimary.withOpacity(0.2)
                        : AppColors.accentBlue.withOpacity(0.15))
                  : isDark
                  ? AppColors.darkBgSurface
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: expanded
                    ? (isDark
                          ? AppColors.darkButtonsPrimary
                          : AppColors.accentBlue)
                    : isDark
                    ? AppColors.borderSubtle
                    : Colors.grey.shade300,
              ),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (expanded) {
                    _expandedOrders.remove(order.id);
                  } else {
                    _expandedOrders.add(order.id);
                  }
                });
              },
              icon: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: expanded
                    ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.accentBlue)
                    : isDark
                    ? AppColors.darkTextSecondary
                    : Colors.black87,
                size: screenWidth > 800 ? 22 : 18,
              ),
              tooltip: expanded ? 'Hide Details' : 'View Details',
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderDetails(Order order, double screenWidth, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 20,
      ),
      color: isDark
          ? AppColors.darkButtonsPrimary.withOpacity(0.08)
          : AppColors.accentBlue.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkButtonsPrimary
                  : AppColors.accentBlue,
              fontSize: screenWidth > 800 ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgElevated : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderSubtle
                        : Colors.blue.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: screenWidth > 800 ? 4 : 3,
                      child: Text(
                        it.productName ?? 'Product ${it.productId}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth > 800 ? 14 : 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'x${it.quantity}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey.shade700,
                          fontSize: screenWidth > 800 ? 14 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '\$${it.unitPrice.toStringAsFixed(2)} each',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey.shade700,
                          fontSize: screenWidth > 800 ? 14 : 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '\$${(it.total).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth > 800 ? 16 : 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final int flex;
  final double screenWidth;
  final bool isDark;

  const _HeaderText(
    this.text, {
    required this.flex,
    required this.screenWidth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
          fontSize: screenWidth > 800 ? 13 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  final String text;
  final int flex;
  final double screenWidth;
  final bool isDark;
  final bool isBold;
  final Color? color;

  const _RowText(
    this.text, {
    required this.flex,
    required this.screenWidth,
    required this.isDark,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? (isDark ? AppColors.darkTextPrimary : Colors.black87),
          fontSize: screenWidth > 800 ? 15 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
