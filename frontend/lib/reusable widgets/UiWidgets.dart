import 'package:flutter/material.dart';
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
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 4,
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
          Icon(
            icon,
            color: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
            size: 20,
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
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

// Widget buildSidebar(
//     BuildContext context,
//     bool isDark,
//     ProductsProvider productsProv,
//   ) {
//     final sidebarWidth = _sidebarExpanded
//         ? 280.0
//         : 100.0; // DRIVING ME CRAZYYYYYYYY

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 50), // MARK: SIDEBAR TIMNE
//       width: sidebarWidth,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated,
//         border: Border(
//           right: BorderSide(
//             color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
//             width: 1,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(2, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Sidebar Header with Toggle
//           Container(
//             height: 80,
//             padding: EdgeInsets.symmetric(
//               horizontal: _sidebarExpanded ? 16 : 8,
//             ),
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
//                 ),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (_sidebarExpanded)
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: isDark
//                                 ? AppColors.darkButtonsPrimary.withOpacity(0.2)
//                                 : AppColors.accentBlue.withOpacity(0.2),
//                           ),
//                           child: Icon(
//                             Icons.store,
//                             color: isDark
//                                 ? AppColors.darkButtonsPrimary
//                                 : AppColors.accentBlue,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'POS System',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: isDark
//                                   ? AppColors.darkTextPrimary
//                                   : AppColors.lightTextPrimary,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   // Container(
//                   //   width: 40,
//                   //   height: 40,
//                   //   decoration: BoxDecoration(
//                   //     borderRadius: BorderRadius.circular(8),
//                   //     color: isDark
//                   //         ? AppColors.darkButtonsPrimary.withOpacity(0.2)
//                   //         : AppColors.accentBlue.withOpacity(0.2),
//                   //   ),
//                   //   child: Icon(
//                   //     Icons.store,
//                   //     color: isDark
//                   //         ? AppColors.darkButtonsPrimary
//                   //         : AppColors.accentBlue,
//                   //     size: 24,
//                   //   ),
//                   // ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: isDark
//                           ? AppColors.darkButtonsPrimary.withOpacity(0.2)
//                           : AppColors.accentBlue.withOpacity(0.2),
//                     ),
//                     child: Icon(
//                       Icons.store,
//                       color: isDark
//                           ? AppColors.darkButtonsPrimary
//                           : AppColors.accentBlue,
//                       size: 24,
//                     ),
//                   ),
//                 IconButton(
//                   icon: Icon(
//                     _sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
//                     color: isDark
//                         ? AppColors.darkTextMuted
//                         : AppColors.lightTextMuted,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _sidebarExpanded = !_sidebarExpanded;
//                     });
//                   },
//                   tooltip: _sidebarExpanded
//                       ? 'Collapse sidebar'
//                       : 'Expand sidebar',
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(
//                     minWidth: 20,
//                     minHeight: 40,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Sidebar Menu Items
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),

//                   // Theme Toggle
//                   buildSidebarMenuItem(
//                     icon: Icons.light_mode,
//                     label: 'Theme',
//                     isDark: isDark,
//                     onTap: () {
//                       context.read<ThemeProvider>().toggleTheme();
//                     },
//                     isExpanded: _sidebarExpanded,
//                   ),

//                   // Refresh Button
//                   buildSidebarMenuItem(
//                     icon: Icons.refresh,
//                     label: 'Refresh',
//                     isDark: isDark,
//                     onTap: () {
//                       productsProv.refresh();
//                       context.read<CategoriesProvider>().loadCategories();
//                     },
//                     isExpanded: _sidebarExpanded,
//                   ),

//                   // Add Category Button
//                   buildSidebarMenuItem(
//                     icon: Icons.add,
//                     label: 'Add Category',
//                     isDark: isDark,
//                     onTap: () async {
//                       final success = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => const AddCategoryDialog(),
//                       );
//                       if (success == true) {
//                         context.read<CategoriesProvider>().loadCategories();
//                       }
//                     },
//                     isExpanded: _sidebarExpanded,
//                   ),

//                   // Orders Button
//                   buildSidebarMenuItem(
//                     icon: Icons.receipt_long,
//                     label: 'Orders',
//                     isDark: isDark,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const OrdersPage(),
//                         ),
//                       );
//                     },
//                     isExpanded: _sidebarExpanded,
//                   ),

//                   // Filter Button
//                   buildSidebarMenuItem(
//                     icon: Icons.filter_list,
//                     label: 'Filters',
//                     isDark: isDark,
//                     onTap: () {
//                       openFilterSheet(context);
//                     },
//                     isExpanded: _sidebarExpanded,
//                   ),

//                   // Add Product Button
//                   buildSidebarMenuItem(
//                     icon: Icons.add,
//                     label: 'Add Product',
//                     isDark: isDark,
//                     onTap: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) => const Productdialogwidget(),
//                       );
//                     },
//                     isExpanded: _sidebarExpanded,
//                   ),

//                   // Separator
//                   if (_sidebarExpanded)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 20,
//                       ),
//                       child: Divider(
//                         color: isDark
//                             ? AppColors.borderSubtle
//                             : Colors.grey.shade300,
//                         thickness: 1,
//                       ),
//                     ),

//                   // System Settings (if needed later)
//                   if (_sidebarExpanded)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'SYSTEM',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: isDark
//                                   ? AppColors.darkTextMuted
//                                   : AppColors.lightTextMuted,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           buildSidebarMenuItem(
//                             icon: Icons.settings,
//                             label: 'Settings',
//                             isDark: isDark,
//                             onTap: () {},
//                             isExpanded: _sidebarExpanded,
//                           ),
//                           buildSidebarMenuItem(
//                             icon: Icons.help_outline,
//                             label: 'Help',
//                             isDark: isDark,
//                             onTap: () {},
//                             isExpanded: _sidebarExpanded,
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // User Profile Section
//           Container(
//             padding: EdgeInsets.all(_sidebarExpanded ? 16 : 12),
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                   color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: isDark
//                         ? AppColors.darkButtonsPrimary
//                         : AppColors.accentBlue,
//                   ),
//                   child: Icon(Icons.person, color: Colors.white, size: 20),
//                 ),
//                 if (_sidebarExpanded) ...[
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Admin',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: isDark
//                                 ? AppColors.darkTextPrimary
//                                 : AppColors.lightTextPrimary,
//                           ),
//                         ),
//                         Text(
//                           'admin@pos.com',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: isDark
//                                 ? AppColors.darkTextMuted
//                                 : AppColors.lightTextMuted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
