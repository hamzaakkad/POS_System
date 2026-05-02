import 'package:flutter/material.dart';
import 'package:pos_system/pages/Splash_screen.dart';
import 'package:pos_system/pages/payment_page.dart';
import 'package:pos_system/pages/pos_dashboard.dart';
import 'package:pos_system/providers/cart_provider.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:pos_system/providers/account_provider.dart';
import 'package:pos_system/services/account_service.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'reusable widgets/AppColors.dart';
import 'providers/payments_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider()..fetchProducts(),
        ),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => PaymentsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final accountService = AccountService();
  @override
  void initState() {
    super.initState();
    accountService.loadLoginStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    // final accountProvider = context.watch<AccountProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      onGenerateRoute: (settings) {
        if (settings.name == '/payment') {
          // Handle arguments (e.g., 192)
          dynamic args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => PaymentPage(orderId: args),
          );
        }
        return null;
      },
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBgPrimary,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBgPrimary,
      ),

      home: const SplashScreen(),
      // home: const PosDashboardPage(),
    );
  }
}
