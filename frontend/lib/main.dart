import 'package:flutter/material.dart';
import 'package:pos_system/providers/cart_provider.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/providers/orders_provider.dart';
import 'package:provider/provider.dart';
import '/pages/pos_dashboard.dart';
import 'package:http/http.dart' as http;
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'reusable widgets/AppColors.dart';

import 'pages/products_page.dart';

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
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBgPrimary,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBgPrimary,
      ),

      home: const PosDashboardPage(),
    );
  }
}
