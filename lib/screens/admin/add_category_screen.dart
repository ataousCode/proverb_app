import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/proverb_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_dialog.dart';
import '../../utils/validators.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final ProverbService _proverbService = ProverbService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _proverbService.addCategory(
        _nameController.text.trim(),
        _imageFile!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category added successfully')));

      // Clear form after successful addition
      _nameController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: e.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Category')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    image:
                        _imageFile != null
                            ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      _imageFile == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey[500],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to select category image',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          )
                          : null,
                ),
              ),
              SizedBox(height: 24),

              // Category name
              CustomTextField(
                controller: _nameController,
                label: 'Category Name',
                hint: 'Enter the category name',
                validator:
                    (value) =>
                        Validators.validateRequired(value, 'Category name'),
              ),
              SizedBox(height: 32),

              // Add button
              CustomButton(
                text: 'Add Category',
                isLoading: _isLoading,
                onPressed: _addCategory,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
