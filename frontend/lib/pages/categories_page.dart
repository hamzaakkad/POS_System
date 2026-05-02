import 'package:flutter/material.dart';
import 'package:pos_system/providers/categories_provider.dart';
import 'package:pos_system/reusable%20widgets/UiWidgets.dart';
import 'package:provider/provider.dart';
import '../models/categories_model.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  /// i should have made widgets but its okay for now :)
  /// i did -_-
  @override
  State<CategoriesPage> createState() => CategoriesPageState();
}

class CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _addController = TextEditingController();
  final editCategoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesProvider>().init();
    });
  }

  @override
  void dispose() {
    editCategoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final provider = context.watch<CategoriesProvider>();

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
          'CATEGORIES',
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

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSidebar(
                  context: context,
                  isDark: isDark,
                  sidebarExpanded: false,
                  showExpandButton: false,
                  isInCategories: true,
                  isInOrders: false,
                  isInProducts: false,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBgElevated
                          : AppColors.lightBgElevated,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInputSection(isDark, screenWidth, provider),
                        _tableHeader(screenWidth, isDark),
                        Container(
                          height: 1,
                          color: isDark
                              ? AppColors.borderSubtle
                              : Colors.grey.shade300,
                        ),
                        Expanded(
                          child: provider.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentBlue,
                                  ),
                                )
                              : _buildCategoryList(
                                  isDark,
                                  screenWidth,
                                  provider,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputSection(
      bool isDark, double screenWidth, CategoriesProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Enter category name...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBgPrimary
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (_addController.text.isNotEmpty) {
                await provider.addCategory(
                  CategoriesModel(name: _addController.text),
                );
                _addController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkButtonsPrimary
                  : AppColors.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "ADD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(double screenWidth, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 800 ? 24 : 16,
        vertical: 15,
      ),
      child: Row(
        children: [
          _HeaderText('ID', flex: 1, screenWidth: screenWidth, isDark: isDark),
          _HeaderText(
            'CATEGORY NAME',
            flex: 4,
            screenWidth: screenWidth,
            isDark: isDark,
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
      bool isDark, double screenWidth, CategoriesProvider provider) {
    if (provider.categories.isEmpty) {
      return Center(
        child: Text(
          "No categories available",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }
    return ListView.builder(
      itemCount: provider.categories.length,
      itemBuilder: (context, index) {
        final cat = provider.categories[index];
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 800 ? 24 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderSubtle : Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text("${cat.id ?? '-'}", style: _rowStyle(isDark)),
              ),
              Expanded(
                flex: 4,
                child: Text(cat.name, style: _rowStyle(isDark, bold: true)),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.yellow.shade200),
                onPressed: () => provider.editCategory(
                  context,
                  cat.id,
                  editCategoryNameController,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => provider.confirmDelete(context, cat),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle _rowStyle(bool isDark, {bool bold = false}) => TextStyle(
        color: isDark ? AppColors.darkTextPrimary : Colors.black87,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: 15,
      );
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
        ),
      ),
    );
  }
}