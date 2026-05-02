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
