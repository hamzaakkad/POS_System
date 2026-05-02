import 'package:flutter/material.dart';
import 'package:pos_system/models/payments_model.dart';
import 'package:pos_system/providers/payments_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../reusable widgets/AppColors.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final Set<int> _expandedOrders = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentsProvider>().fetchPayments();
    });
  }

  Future<void> _refresh() async {
    await context.read<PaymentsProvider>().fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBgElevated
            : AppColors.lightBgElevated,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PAYMENTS',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 24),

                    /// PAYMENTS TABLE
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
                              child: Consumer<PaymentsProvider>(
                                builder: (context, paymentsProvider, _) {
                                  if (paymentsProvider.loading) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: isDark
                                            ? AppColors.darkButtonsPrimary
                                            : AppColors.accentBlue,
                                      ),
                                    );
                                  }
                                  if (paymentsProvider.error != null) {
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
                                              'Error: ${paymentsProvider.error}',
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
                                  final payments = paymentsProvider.orders;
                                  if (payments.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment_outlined,
                                            color: isDark
                                                ? AppColors.darkTextMuted
                                                : Colors.grey.shade300,
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No payments yet',
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
                                    itemCount: payments.length,
                                    itemBuilder: (context, index) {
                                      final payment = payments[index];
                                      final expanded = _expandedOrders.contains(
                                        payment.id,
                                      );
                                      return Column(
                                        children: [
                                          _paymentRow(
                                            payment,
                                            expanded,
                                            screenWidth,
                                            context,
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
                  'PAYMENT ID',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                _HeaderText(
                  'ORDER ID',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                _HeaderText(
                  'AMOUNT',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                _HeaderText(
                  'METHOD',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                if (screenWidth > 800)
                  _HeaderText(
                    'ACTIONS',
                    flex: 2,
                    screenWidth: screenWidth,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(
    PaymentsModel payment,
    bool expanded,
    double screenWidth,
    BuildContext context,
  ) {
    final isDark = context.watch<ThemeProvider>().isDark;

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
                  payment.id?.toString() ?? 'N/A',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                  isBold: true,
                ),
                _RowText(
                  payment.order_id?.toString() ?? 'N/A',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                _RowText(
                  '\$${_formatPrice(payment.order_price)}',
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                  isBold: true,
                  color: isDark
                      ? AppColors.darkButtonsPrimary
                      : AppColors.accentBlue,
                ),
                _RowText(
                  _getMethodIcon(payment.method),
                  flex: 2,
                  screenWidth: screenWidth,
                  isDark: isDark,
                ),
                if (screenWidth > 800)
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.receipt_long,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () {},
                          tooltip: 'Generate Receipt',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    if (price is num) {
      return price.toStringAsFixed(2);
    }
    if (price is String) {
      try {
        return double.parse(price).toStringAsFixed(2);
      } catch (e) {
        return '0.00';
      }
    }
    return '0.00';
  }

  String _getMethodIcon(String? method) {
    if (method == null) return 'N/A';

    switch (method.toLowerCase()) {
      case 'cash':
        return '💵 Cash';
      case 'credit':
        return '💳 Credit Card';
      case 'debit':
        return '💳 Debit Card';
      case 'mobile':
        return '📱 Mobile Payment';
      case 'online':
        return '🌐 Online';
      default:
        return '💳 $method'; //all these payment methods are for later usage if the engineer asked me for
    }
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
