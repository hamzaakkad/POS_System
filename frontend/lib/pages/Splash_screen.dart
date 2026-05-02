import 'package:flutter/material.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/providers/account_provider.dart';
import 'package:pos_system/reusable%20widgets/AppColors.dart';
import 'package:pos_system/pages/pos_dashboard.dart';
import 'package:pos_system/pages/auth_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // context.read<ProductsProvider>().fetchProducts();
    // context.read<ProductsProvider>().fetchProductsPageProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
      context.read<CategoriesProvider>().init();
    });
    // context.read<OrdersProvider>().loadOrders();
    // Navigate to appropriate screen after 2 seconds based on authentication

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final accountProvider = context.read<AccountProvider>();
        final nextScreen = accountProvider.isAuthenticated
            ? const PosDashboardPage()
            : const AuthPage();

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
              isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Store icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBgElevated
                      : AppColors.lightBgElevated,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.store,
                  size: 80,
                  color: isDark
                      ? AppColors.darkButtonsPrimary
                      : AppColors.accentBlue,
                ),
              ),
              const SizedBox(height: 30),
              // App name
              Text(
                'POS SYSTEM',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              Text(
                'Point of Sale',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 50),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
                ),
                backgroundColor: isDark
                    ? AppColors.darkBgSurface
                    : AppColors.lightBgSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
