import 'package:flutter/material.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:provider/provider.dart';
import '../models/orders_model.dart';
import '../reusable widgets/AppColors.dart';
import 'single_order_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final Set<int> _expandedOrders = {};
  final TextEditingController _paidPriceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Use microtask for the initial load
    context.read<OrdersProvider>().isLoading = true;
    Future.microtask(() => context.read<OrdersProvider>().loadOrders());

    _scrollController.addListener(_scrollListener);
    Future.delayed(const Duration(seconds: 2), () {
      // if (mounted) {
      // context.read<OrdersProvider>().loadOrders();
      // initState();
      // }
      setState(() {
        context.read<OrdersProvider>().isLoading = false;
      });
    });
  }

  void _scrollListener() {
    // Grab the provider here to ensure it's fresh
    final provider = context.read<OrdersProvider>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchNextBatch();
      }
    }
  }

  @override
  void dispose() {
    _paidPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _showDeleteDialog(Order order, BuildContext context) {
  //   final isDark = context.read<ThemeProvider>().isDark;
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: isDark
  //           ? AppColors.darkBgElevated
  //           : AppColors.lightBgElevated,
  //       title: const Text("Delete Order?"),
  //       content: Text("Are you sure you want to delete Order #${order.id}?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await context.read<OrdersProvider>().deleteOrder(order.id);
  //           },
  //           child: const Text("Delete", style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    // final productsProv = context.read<ProductsProvider>();

    // Determine colors once to keep the UI tree clean
    final bgColor = isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary;
    final cardColor = isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ORDERS',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: cardColor),
        child: Row(
          children: [
            buildSidebar(
              context: context,
              isDark: isDark,
              sidebarExpanded: false,
              showExpandButton: false,
              isInCategories: false,
              isInOrders: true,
              isInProducts: false,
            ),
            // FIX: Use Expanded here so the content fills the remaining width
            Expanded(
              child: Column(
                children: [
                  _tableHeader(screenWidth, isDark),
                  const Divider(height: 1),
                  Expanded(child: _buildList(isDark, screenWidth)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool isDark, double screenWidth) {
    final provider = context.read<OrdersProvider>();
    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.orders.isEmpty) {
      return const Center(child: Text("No orders found."));
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshOrders(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        // Add 1 extra item to show the loader at the bottom and fix that annoying bug
        itemCount: provider.orders.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.orders.length) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final order = provider.orders[index];
          final expanded = _expandedOrders.contains(order.id);
          return Column(
            children: [
              _orderRow(order, expanded, screenWidth, context),
              // if (expanded) _orderDetails(context, order, screenWidth, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _tableHeader(double screenWidth, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _HeaderText(
            'ORDER NUMBER',
            flex: 5,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          _HeaderText(
            'TOTAL',
            flex: 5,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          _HeaderText(
            'STATUS',
            flex: 2,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          const SizedBox(width: 100), // Space for actions
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
    final isDark = context.read<ThemeProvider>().isDark;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SingleOrderPage(orderId: order.id!)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderSubtle : Colors.grey.shade200,
            ),
          ),
          color: expanded
              ? (isDark ? Colors.white10 : Colors.blue.shade50)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            _RowText(
              'Order #${order.id}',
              flex: 3,
              screenWidth: screenWidth,
              isDark: isDark,
            ),
            _RowText(
              '\$${order.total.toStringAsFixed(2)}',
              flex: 2,
              screenWidth: screenWidth,
              isDark: isDark,
              isBold: true,
            ),
            Expanded(
              flex: 3,
              child: _StatusBadge(
                status: order.order_status ?? 'Pending',
                isDark: isDark,
                screenWidth: screenWidth,
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
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
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

class _RowText extends StatelessWidget {
  final String text;
  final int flex;
  final double screenWidth;
  final bool isDark;
  final bool isBold;
  const _RowText(
    this.text, {
    required this.flex,
    required this.screenWidth,
    required this.isDark,
    this.isBold = false,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isDark;
  final double screenWidth;
  const _StatusBadge({
    required this.status,
    required this.isDark,
    required this.screenWidth,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: status == "Paid"
          ? Colors.green.withOpacity(0.1)
          : status == "Partially Paid"
          ? Colors.orange.withOpacity(0.1)
          : Colors.red.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status,

      style: TextStyle(
        color: status == "Paid"
            ? Colors.green
            : status == "Partially Paid"
            ? Colors.orange
            : Colors.red,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
