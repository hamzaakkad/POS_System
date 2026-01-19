import 'package:flutter/material.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:pos_system/providers/theme_provider.dart';
import 'package:pos_system/reusable%20widgets/AppColors.dart';
import 'package:provider/provider.dart';

class FiltersSheet extends StatelessWidget {
  const FiltersSheet({super.key});

  static void openFilterSheet(BuildContext context) {
    // Imma fetch theme status here to apply its status to the bottom sheets root
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    showModalBottomSheet(
      context: context,
      // Applying dark background to the sheet itself finally this took me sometime
      backgroundColor: isDark
          ? AppColors.darkBgSurface
          : AppColors.lightBgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        final productsProv = sheetContext.watch<ProductsProvider>();
        final isDark = sheetContext.watch<ThemeProvider>().isDark;

        // Helper text style to avoid repetition who likes repetition not me:)
        TextStyle labelStyle = TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 40,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white54 : Colors.black54,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // FILTER OPTIONS
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // STOCK FILTERS SECTION
                      _buildSectionContainer(
                        isDark: isDark,
                        child: Column(
                          children: [
                            _buildListTile(
                              title: 'In stock only',
                              value: productsProv.inStock,
                              isDark: isDark,
                              onChanged: (v) => productsProv.setInStockOnly(v),
                            ),
                            Divider(
                              height: 0,
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade300,
                              indent: 16,
                            ),
                            _buildListTile(
                              title: 'Out of stock',
                              value: productsProv.outOfStock,
                              isDark: isDark,
                              onChanged: (v) =>
                                  productsProv.setOutOfStockOnly(v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text('Price Range', style: labelStyle),

                      const SizedBox(height: 12),

                      // PRICE INPUTS
                      _buildPriceInput(
                        label: 'Minimum Price',
                        hint: '0.00',
                        isDark: isDark,
                        value: productsProv.minPrice?.toDouble(),
                        onSubmitted: (val) => productsProv.setMinPrice(val),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceInput(
                        label: 'Maximum Price',
                        hint: '0.00',
                        isDark: isDark,
                        value: productsProv.maxPrice?.toDouble(),
                        onSubmitted: (val) => productsProv.setMaxPrice(val),
                      ),

                      const SizedBox(height: 24),

                      // SORT SECTION
                      Text('Sort by', style: labelStyle),
                      const SizedBox(height: 12),

                      _buildSectionContainer(
                        isDark: isDark,
                        child: Column(
                          children: [
                            _buildSortTile(
                              title: 'Name (A to Z)',
                              icon: Icons.sort_by_alpha,
                              isDark: isDark,
                              onTap: () {
                                productsProv.sortByName(true);
                                Navigator.pop(sheetContext);
                              },
                            ),
                            Divider(
                              height: 0,
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade300,
                              indent: 16,
                            ),
                            _buildSortTile(
                              title: 'Name (Z to A)',
                              icon: Icons.sort_by_alpha,
                              isDark: isDark,
                              onTap: () {
                                productsProv.sortByNameDESC(true);
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // RESET FILTERS button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    productsProv.resetFilters();
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkButtonsPrimary
                        : const Color(0xFF0277FA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'RESET FILTERS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS TO CLEAN UP THE CODE ---

  static Widget _buildSectionContainer({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgElevated : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  static Widget _buildListTile({
    required String title,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark
              ? AppColors.darkButtonsPrimary
              : AppColors.accentBlue,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  static Widget _buildSortTile({
    required String title,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      ),
      trailing: Icon(
        icon,
        color: isDark ? Colors.white38 : Colors.grey.shade500,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  static Widget _buildPriceInput({
    required String label,
    required String hint,
    required bool isDark,
    required double? value,
    required Function(int) onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgElevated : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            onSubmitted: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null) onSubmitted(parsed.toInt());
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // why ? because as i read that this widget is usually called by the static methode
  }
}
