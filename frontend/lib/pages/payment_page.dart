import 'package:flutter/material.dart';
import 'package:pos_system/models/orders_model.dart';
import 'package:pos_system/providers/account_provider.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:pos_system/providers/payments_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/reusable widgets/AppColors.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  int? orderId;

  PaymentPage({super.key, this.orderId});

  @override
  State<PaymentPage> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final ordersProvider = context.read<OrdersProvider>();
    ordersProvider.calculateChange(amountController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ordersProvider = context.read<OrdersProvider>();
    ordersProvider.fetchOrder(context, widget.orderId, amountController);
  }

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use select for properties that don't change on every keystroke
    final isDark = context.watch<ThemeProvider>().isDark;
    final order = context.select<OrdersProvider, Order?>((p) => p.order);
    final amountToPay = context.select<OrdersProvider, int>(
      (p) => p.amountToPay,
    );
    final isPartialPayment = context.select<OrdersProvider, bool>(
      (p) => p.isPartialPayment,
    );
    final isProcessing = context.select<OrdersProvider, bool>(
      (p) => p.isProcessing,
    );
    final selectedPaymentMethod = context.select<OrdersProvider, String>(
      (p) => p.selectedPaymentMethod,
    );
    // changeAmount is handled separately via Consumer below to avoid full rebuilds

    return Scaffold(
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
                          'PROCESS PAYMENT',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: screenWidth > 800 ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 48), // For balanced spacing
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// MAIN CONTENT
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT COLUMN - ORDER DETAILS
                          Expanded(
                            flex: 2,
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
                              child: Padding(
                                padding: EdgeInsets.all(
                                  screenWidth > 800 ? 24 : 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ORDER SUMMARY',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey.shade600,
                                        fontSize: screenWidth > 800 ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    /// Order ID
                                    if (order != null)
                                      _DetailRow(
                                        label: 'Order ID',
                                        value: order.id.toString(),
                                        isDark: isDark,
                                      ),

                                    /// Items List
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: isDark
                                              ? AppColors.darkBgSurface
                                              : Colors.grey.shade50,
                                        ),
                                        child: order == null
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: ListView.builder(
                                                  itemCount: order.items.length,
                                                  itemBuilder: (context, index) {
                                                    final item =
                                                        order.items[index];
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 8,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? AppColors
                                                                  .darkBgElevated
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color: isDark
                                                              ? AppColors
                                                                    .borderSubtle
                                                              : Colors
                                                                    .blue
                                                                    .shade100,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                              item.productName!,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              'x${item.quantity}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              '\$${item.total.toStringAsFixed(2)}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    /// Totals
                                    if (order != null) ...[
                                      const Divider(),
                                      _DetailRow(
                                        label: 'TOTAL',
                                        value: '\$$amountToPay',
                                        isDark: isDark,
                                        isBold: true,
                                        color: isDark
                                            ? AppColors.darkButtonsPrimary
                                            : AppColors.accentBlue,
                                      ),
                                      if (isPartialPayment)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            'This is the remaining amount to pay.',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: screenWidth > 800 ? 24 : 16),

                          /// RIGHT COLUMN - PAYMENT OPTIONS
                          Expanded(
                            flex: 2,
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
                              child: Padding(
                                padding: EdgeInsets.all(
                                  screenWidth > 800 ? 24 : 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PAYMENT METHOD',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey.shade600,
                                        fontSize: screenWidth > 800 ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    /// Payment Method Selection
                                    GridView.count(
                                      shrinkWrap: true,
                                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 3,
                                      children: [
                                        _PaymentMethodButton(
                                          icon: Icons.payments,
                                          label: 'Cash',
                                          isSelected:
                                              selectedPaymentMethod == 'cash',
                                          onTap: () => context
                                              .read<OrdersProvider>()
                                              .updatePaymentMethod('cash'),
                                          color: Colors.green,
                                          isDark: isDark,
                                        ),
                                        _PaymentMethodButton(
                                          icon: Icons.credit_card,
                                          label: 'Card',
                                          isSelected:
                                              selectedPaymentMethod == 'card',
                                          onTap: () => context
                                              .read<OrdersProvider>()
                                              .updatePaymentMethod('card'),
                                          color: Colors.blue,
                                          isDark: isDark,
                                        ),
                                        _PaymentMethodButton(
                                          icon: Icons.qr_code,
                                          label: 'QR Code',
                                          isSelected:
                                              selectedPaymentMethod == 'qr',
                                          onTap: () => context
                                              .read<OrdersProvider>()
                                              .updatePaymentMethod('qr'),
                                          color: Colors.purple,
                                          isDark: isDark,
                                        ),
                                        if (screenWidth > 600) ...[
                                          _PaymentMethodButton(
                                            icon: Icons.phone_android,
                                            label: 'Mobile',
                                            isSelected:
                                                selectedPaymentMethod ==
                                                'mobile',
                                            onTap: () => context
                                                .read<OrdersProvider>()
                                                .updatePaymentMethod('mobile'),
                                            color: Colors.orange,
                                            isDark: isDark,
                                          ),
                                          _PaymentMethodButton(
                                            icon: Icons.account_balance,
                                            label: 'Bank',
                                            isSelected:
                                                selectedPaymentMethod == 'bank',
                                            onTap: () => context
                                                .read<OrdersProvider>()
                                                .updatePaymentMethod('bank'),
                                            color: Colors.teal,
                                            isDark: isDark,
                                          ),
                                          _PaymentMethodButton(
                                            icon: Icons.receipt_long,
                                            label: 'Invoice',
                                            isSelected:
                                                selectedPaymentMethod ==
                                                'invoice',
                                            onTap: () => context
                                                .read<OrdersProvider>()
                                                .updatePaymentMethod('invoice'),
                                            color: Colors.brown,
                                            isDark: isDark,
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    /// Card Details (for card payment)
                                    if (selectedPaymentMethod == 'card')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CARD DETAILS',
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : Colors.grey.shade600,
                                              fontSize: screenWidth > 800
                                                  ? 14
                                                  : 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: _cardNumberController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Card Number',
                                              hintText: '1234 5678 9012 3456',
                                              filled: true,
                                              fillColor: isDark
                                                  ? AppColors.darkBgSurface
                                                  : Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderSubtle
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderSubtle
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: _expiryController,
                                                  keyboardType:
                                                      TextInputType.datetime,
                                                  decoration: InputDecoration(
                                                    labelText: 'Expiry Date',
                                                    hintText: 'MM/YY',
                                                    filled: true,
                                                    fillColor: isDark
                                                        ? AppColors
                                                              .darkBgSurface
                                                        : Colors.grey.shade50,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? AppColors
                                                                  .borderSubtle
                                                            : Colors
                                                                  .grey
                                                                  .shade300,
                                                      ),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? AppColors
                                                                  .borderSubtle
                                                            : Colors
                                                                  .grey
                                                                  .shade300,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextField(
                                                  controller: _cvvController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'CVV',
                                                    hintText: '123',
                                                    filled: true,
                                                    fillColor: isDark
                                                        ? AppColors
                                                              .darkBgSurface
                                                        : Colors.grey.shade50,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? AppColors
                                                                  .borderSubtle
                                                            : Colors
                                                                  .grey
                                                                  .shade300,
                                                      ),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? AppColors
                                                                  .borderSubtle
                                                            : Colors
                                                                  .grey
                                                                  .shade300,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _cardHolderController,
                                            decoration: InputDecoration(
                                              labelText: 'Cardholder Name',
                                              hintText: 'John Doe',
                                              filled: true,
                                              fillColor: isDark
                                                  ? AppColors.darkBgSurface
                                                  : Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderSubtle
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderSubtle
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    /// Amount Input (for cash)
                                    if (selectedPaymentMethod == 'cash')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'AMOUNT PAID',
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : Colors.grey.shade600,
                                              fontSize: screenWidth > 800
                                                  ? 14
                                                  : 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            key: const ValueKey(
                                              'amount_field',
                                            ), // preserve identity
                                            controller: amountController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              prefixIcon: const Icon(
                                                Icons.attach_money_rounded,
                                              ),
                                              hintText: 'Enter amount received',
                                              filled: true,
                                              fillColor: isDark
                                                  ? AppColors.darkBgSurface
                                                  : Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderSubtle
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: isDark
                                                      ? AppColors.borderSubtle
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Use Consumer to rebuild only the change amount text
                                          Consumer<OrdersProvider>(
                                            builder: (context, provider, child) {
                                              final change =
                                                  provider.changeAmount;
                                              if (change <= 0)
                                                return const SizedBox.shrink();
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  'Change: \$${change.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade600,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 24),
                                    const SizedBox(height: 32),

                                    /// Process Payment Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: isProcessing || order == null
                                            ? null
                                            : () => context
                                                  .read<OrdersProvider>()
                                                  .processPayment(
                                                    context,
                                                    amountController,
                                                    widget.orderId,
                                                  ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark
                                              ? AppColors.darkButtonsPrimary
                                              : AppColors.accentBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                        child: isProcessing
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: screenWidth > 800
                                                        ? 22
                                                        : 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'PROCESS PAYMENT',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth > 800
                                                          ? 18
                                                          : 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isBold;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  color ??
                  (isDark ? AppColors.darkTextPrimary : Colors.black87),
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(isDark ? 0.3 : 0.2)
              : isDark
              ? AppColors.darkBgSurface
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                ? AppColors.borderSubtle
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : isDark
                  ? AppColors.darkTextSecondary
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : isDark
                    ? AppColors.darkTextSecondary
                    : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
