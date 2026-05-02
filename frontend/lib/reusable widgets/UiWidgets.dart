import 'package:flutter/material.dart';
import 'package:pos_system/pages/auth_page.dart';
import 'package:pos_system/pages/categories_page.dart';
import 'package:pos_system/pages/orders_page.dart';
import 'package:pos_system/pages/payments_page.dart';
import 'package:pos_system/pages/pos_dashboard.dart';
import 'package:pos_system/pages/products_page.dart';
import 'package:pos_system/pages/roles&permissions_page.dart';
import 'package:pos_system/pages/user_profile_page.dart';
import 'package:pos_system/providers/account_provider.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'AppColors.dart';
// ================= UI WIDGETS =================

Widget buildHeaderIconButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback onPressed,
  required Color color,
  required Color backgroundColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
    ),
  );
}

Widget buildSidebarMenuItem({
  required IconData icon,
  required String label,
  required bool isDark,
  required VoidCallback onTap,
  required bool isExpanded,
  int? iconSize,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(
              icon,
              color: isDark
                  ? AppColors.darkButtonsPrimary
                  : AppColors.accentBlue,
              size: 22,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

void SnackbarWidget(String text, Color color, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Widget buildSidebar({
  required BuildContext context,
  required bool isDark,
  // required ProductsProvider productsProv,
  required bool sidebarExpanded,
  VoidCallback? onToggleSidebar,
  required bool showExpandButton,
  required bool isInCategories,
  required bool isInOrders,
  required bool isInProducts,
}) {
  final sidebarWidth = sidebarExpanded ? 280.0 : 75.0;
  final accountProvider = context.watch<AccountProvider>();
  return AnimatedContainer(
    duration: const Duration(milliseconds: 50),
    width: sidebarWidth,
    height: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
      border: Border(
        right: BorderSide(
          color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(2, 0),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: sidebarExpanded ? 16 : 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sidebarExpanded)
                Expanded(
                  child: Row(
                    children: [
                      // Icon(
                      //   Icons.store,
                      //   color: isDark
                      //       ? AppColors.darkButtonsPrimary
                      //       : AppColors.accentBlue,
                      //   size: 20,
                      // ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'POS System',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.store,
                  color: isDark
                      ? AppColors.darkButtonsPrimary
                      : AppColors.accentBlue,
                  size: 24,
                ),

              if (showExpandButton)
                IconButton(
                  icon: Icon(
                    sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  onPressed: onToggleSidebar,
                  tooltip: sidebarExpanded
                      ? 'Collapse sidebar'
                      : 'Expand sidebar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 40,
                  ),
                ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                buildSidebarMenuItem(
                  icon: Icons.light_mode,
                  label: 'Theme',
                  isDark: isDark,
                  onTap: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  isExpanded: sidebarExpanded,
                ),
                // if (permissionsModel.can('can edit categories'))
                if (accountProvider.canAccessPage('categories') &&
                    !isInCategories)
                  buildSidebarMenuItem(
                    icon: Icons.category,
                    label: 'Categories',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesPage(),
                        ),
                      );
                    },
                    isExpanded: sidebarExpanded,
                  ),
                // if (_canAccessPage('orders'))
                // if (accountProvider.canAccessPage('orders'))
                if (!isInOrders)
                  buildSidebarMenuItem(
                    icon: Icons.receipt_long,
                    label: 'Orders',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersPage(),
                        ),
                      );
                    },
                    isExpanded: sidebarExpanded,
                  ),
                // if (_canAccessPage('products') &&
                // _permissionsModel.can('can edit products'))
                if (accountProvider.canAccessPage('products') && !isInProducts)
                  buildSidebarMenuItem(
                    icon: Icons.shopping_cart_sharp,
                    label: 'Products',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsPage(),
                        ),
                      );
                    },
                    isExpanded: sidebarExpanded,
                  ),
                // if (_canAccessPage('payments'))
                if (accountProvider.canAccessPage('payments'))
                  buildSidebarMenuItem(
                    icon: IconData(0xe481, fontFamily: 'MaterialIcons'),
                    label: 'Payments',
                    isDark: isDark,
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentsPage(),
                        ),
                      );

                      // await _fetchPaymentsService.fetchPayments();
                    },
                    isExpanded: sidebarExpanded,
                  ),

                if (sidebarExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Divider(
                      color: isDark
                          ? AppColors.borderSubtle
                          : Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),

                if (sidebarExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SYSTEM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // if (_permissionsModel.can('is admin'))
                        // if (accountProvider.canAccessPage('is admin') ||
                        //     accountProvider.canAccessPage('is admin'))
                        if (accountProvider.canAccessPage('settings'))
                        /// finlly fixed it back 
                        /// the route to know pages information such as key and everything is http://localhost:5000/api/admin/page-permissions
                          buildSidebarMenuItem(
                            icon: Icons.admin_panel_settings_outlined,
                            label: 'Roles & Permissions',
                            isDark: isDark,
                            onTap: () async {
                              final adminId = context
                                  .read<AccountProvider>()
                                  .currentUser
                                  ?.id;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                            isExpanded: sidebarExpanded,
                          ),
                        buildSidebarMenuItem(
                          icon: Icons.logout_outlined,
                          label: 'Logout',
                          isDark: isDark,
                          onTap: () {
                            context.read<AccountProvider>().logout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AuthPage(isLogin: true),
                              ),
                            );
                          },
                          isExpanded: sidebarExpanded,
                        ),
                        buildSidebarMenuItem(
                          icon: Icons.help_outline,
                          label: 'Help',
                          isDark: isDark,
                          onTap: () {
                            // _getUserPermissions(30);
                          },
                          isExpanded: sidebarExpanded,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.all(sidebarExpanded ? 16 : 6),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? AppColors.darkButtonsPrimary
                      : AppColors.accentBlue,
                ),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 14),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfilePage(),
                    ),
                  ),
                ),
              ),
              if (sidebarExpanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Consumer<AccountProvider>(
                    builder: (context, accountProvider, _) {
                      final userName =
                          accountProvider.currentUser?.name ?? 'Guest User';
                      final userEmail =
                          accountProvider.currentUser?.email ?? 'No email';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Keeps column compact
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
