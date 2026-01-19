import 'package:flutter/material.dart';
import 'package:pos_system/providers/product_provider.dart';
import 'package:provider/provider.dart';

void openFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (sheetContext) {
      final productsProv = sheetContext.watch<ProductsProvider>();

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
                const Text(
                  'Filter Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black54,
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
                    // STOCK FILTERS
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'In stock only',
                              style: TextStyle(color: Colors.black87),
                            ),
                            trailing: Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: productsProv.inStock,
                                onChanged: (v) =>
                                    productsProv.setInStockOnly(v),
                                activeColor: const Color(0xFF0277FA),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          const Divider(
                            height: 0,
                            color: Colors.grey,
                            indent: 16,
                          ),
                          ListTile(
                            title: const Text(
                              'Out of stock',
                              style: TextStyle(color: Colors.black87),
                            ),
                            trailing: Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: productsProv.outOfStock,
                                onChanged: (v) =>
                                    productsProv.setOutOfStockOnly(v),
                                activeColor: const Color(0xFF0277FA),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PRICE RANGE
                    const Text(
                      'Price Range',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Column(
                      children: [
                        // Minimum Price
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Minimum Price',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: TextField(
                                  controller: TextEditingController(
                                    text:
                                        productsProv.minPrice?.toStringAsFixed(
                                          2,
                                        ) ??
                                        '',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    hintText: '\$0.00',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    prefixText: '\$',
                                    prefixStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  // onChanged: (value) {
                                  //   final parsed = double.tryParse(value);
                                  //   if (parsed != null) {
                                  //     //productsProv.setMinPrice(parsed);
                                  //     productsProv.setMinPrice(
                                  //       parsed.toInt(),
                                  //     );
                                  //   }
                                  // },// this is causing conflict while testing imma implement it later or maybe no
                                  onSubmitted: (value) {
                                    final parsed = double.tryParse(value);
                                    if (parsed != null) {
                                      //productsProv.setMinPrice(parsed);
                                      productsProv.setMinPrice(parsed.toInt());
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Maximum Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Maximum Price',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextField(
                                controller: TextEditingController(
                                  text:
                                      productsProv.maxPrice?.toStringAsFixed(
                                        2,
                                      ) ??
                                      '',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  hintText: '\$0.00',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixText: '\$',
                                  prefixStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                // onChanged: (value) {
                                //   final parsed = double.tryParse(value);
                                //   if (parsed != null) {
                                //     //   productsProv.setMaxPrice(parsed);
                                //   }
                                // },
                                onSubmitted: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null) {
                                    //productsProv.setMinPrice(parsed);
                                    productsProv.setMaxPrice(parsed.toInt());
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SORT SECTION
                    const Text(
                      'Sort by',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // ListTile(
                          //   title: const Text(
                          //     'Price (Low to High)',
                          //     style: TextStyle(color: Colors.black87),
                          //   ),
                          //   trailing: Icon(
                          //     Icons.arrow_upward,
                          //     color:
                          //         //      productsProv.currentSort == SortBy.priceAsc
                          //         //     ? const Color(0xFF0277FA)
                          //         //      :
                          //         Colors.grey.shade500,
                          //   ),
                          //   onTap: () {
                          //     productsProv.sortByPrice(true);
                          //     Navigator.pop(sheetContext);
                          //   },
                          //   contentPadding: const EdgeInsets.symmetric(
                          //     horizontal: 16,
                          //     vertical: 12,
                          //   ),
                          // ),
                          // const Divider(
                          //   height: 0,
                          //   color: Colors.grey,
                          //   indent: 16,
                          // ),
                          ListTile(
                            title: const Text(
                              'Name (A to Z)',
                              style: TextStyle(color: Colors.black87),
                            ),
                            trailing: Icon(
                              Icons.sort_by_alpha,
                              color:
                                  //productsProv.currentSort == SortBy.nameAsc
                                  // ? const Color(0xFF0277FA)
                                  //: Colors.grey.shade500,
                                  Colors.grey.shade500,
                            ),
                            onTap: () {
                              productsProv.sortByName(true);
                              Navigator.pop(sheetContext);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          const Divider(
                            height: 0,
                            color: Colors.grey,
                            indent: 16,
                          ),
                          ListTile(
                            title: const Text(
                              'Name (Z to A)',
                              style: TextStyle(color: Colors.black87),
                            ),
                            trailing: Icon(
                              Icons.sort_by_alpha,
                              color:
                                  //productsProv.currentSort == SortBy.nameAsc
                                  // ? const Color(0xFF0277FA)
                                  //: Colors.grey.shade500,
                                  Colors.grey.shade500,
                            ),
                            onTap: () {
                              productsProv.sortByNameDESC(true);
                              Navigator.pop(sheetContext);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          // const Divider(
                          //   height: 0,
                          //   color: Colors.grey,
                          //   indent: 16,
                          // ),

                          // ListTile(
                          //   title: const Text(
                          //     'Price (High to Low)',
                          //     style: TextStyle(color: Colors.black87),
                          //   ),
                          //   trailing: Icon(
                          //     Icons.arrow_downward,
                          //     color:
                          //         //      productsProv.currentSort == SortBy.priceDesc
                          //         //   ? const Color(0xFF0277FA)
                          //         // : Colors.grey.shade500,
                          //         Colors.grey.shade500,
                          //   ),
                          //   onTap: () {
                          //     productsProv.sortByPrice(false);
                          //     Navigator.pop(sheetContext);
                          //   },
                          //   contentPadding: const EdgeInsets.symmetric(
                          //     horizontal: 16,
                          //     vertical: 12,
                          //   ),
                          // ),
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
                  backgroundColor: const Color(0xFF0277FA),
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
