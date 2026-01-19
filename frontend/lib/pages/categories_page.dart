import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categories_model.dart';
import '../services/categories_service.dart';
import '../providers/theme_provider.dart';
import '../reusable widgets/AppColors.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  // i should have made widgets but its okay for now :)
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FetchCategoriesService _fetchService = FetchCategoriesService();
  final PostCategoryService _postService = PostCategoryService();
  final DeleteCategoryService _deleteService = DeleteCategoryService();

  List<CategoriesModel> _categories = [];
  bool _isLoading = true;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  Future<void> _refreshCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _fetchService.fetchCategories();
      setState(() => _categories = data);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP HEADER Matching my other designs
                    _buildHeader(screenWidth, isDark),

                    const SizedBox(height: 24),

                    /// CATEGORY MANAGEMENT BOX
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
                            _buildInputSection(isDark, screenWidth),
                            _tableHeader(screenWidth, isDark),
                            Container(
                              height: 1,
                              color: isDark
                                  ? AppColors.borderSubtle
                                  : Colors.grey.shade300,
                            ),
                            Expanded(
                              child: _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accentBlue,
                                      ),
                                    )
                                  : _buildCategoryList(isDark, screenWidth),
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

  Widget _buildHeader(double screenWidth, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'CATEGORIES',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontSize: screenWidth > 800 ? 28 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextPrimary,
          ),
          onPressed: _refreshCategories,
        ),
      ],
    );
  }

  Widget _buildInputSection(bool isDark, double screenWidth) {
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
                await _postService.postCategory(
                  CategoriesModel(name: _addController.text),
                );
                _addController.clear();
                _refreshCategories();
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

  Widget _buildCategoryList(bool isDark, double screenWidth) {
    if (_categories.isEmpty) {
      return Center(
        child: Text(
          "No categories available",
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
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
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(cat),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(CategoriesModel cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete ${cat.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _deleteService.deleteCategory(cat.id);
              Navigator.pop(context);
              _refreshCategories();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  TextStyle _rowStyle(bool isDark, {bool bold = false}) => TextStyle(
    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontSize: 15,
  );
}

/// Header Text Widget ( i kept the same design and i think that is better )
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
