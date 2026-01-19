// import 'package:flutter/material.dart';
// import 'package:pos_system/providers/categories_provider.dart';
// import 'package:provider/provider.dart';

// class CategoriesScreen extends StatefulWidget {
//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch data once when the screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CategoriesProvider>().loadCategories();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Categories')),
//       body: Consumer<CategoriesProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.errorMessage.isNotEmpty) {
//             return Center(child: Text('Error: ${provider.errorMessage}'));
//           }

//           if (provider.categories.isEmpty) {
//             return const Center(child: Text('No categories found.'));
//           }

//           return ListView.builder(
//             itemCount: provider.categories.length,
//             itemBuilder: (context, index) {
//               final category = provider.categories[index];
//               return ListTile(
//                 leading: CircleAvatar(child: Text(category.id.toString())),
//                 title: Text(category.name),
//                 onTap: () {
//                   // Handle category selection
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// // for testing purposes only for showing the categories in a seperate ui

import 'package:flutter/material.dart';
import 'package:pos_system/models/categories_model.dart';
import 'package:pos_system/services/categories_service.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final PostCategoryService _service = PostCategoryService();
  bool _isLoading = false;

  void _handleSave() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _service.postCategory(CategoriesModel(name: _controller.text));
      if (mounted) Navigator.pop(context, true); // Return 'true' on success
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: "Enter category name"),
        enabled: !_isLoading,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
