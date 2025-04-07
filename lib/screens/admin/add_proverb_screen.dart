import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../services/proverb_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_dialog.dart';
import '../../utils/validators.dart';

class AddProverbScreen extends StatefulWidget {
  @override
  _AddProverbScreenState createState() => _AddProverbScreenState();
}

class _AddProverbScreenState extends State<AddProverbScreen> {
  final ProverbService _proverbService = ProverbService();
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _authorController = TextEditingController();

  File? _imageFile;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();
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

  Future<void> _addProverb() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _proverbService.addProverb(
        _textController.text.trim(),
        _authorController.text.trim(),
        _imageFile!,
        _selectedCategoryId!,
        _selectedCategoryName!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Proverb added successfully')));

      // Clear form after successful addition
      _textController.clear();
      _authorController.clear();
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
      appBar: AppBar(title: Text('Add New Proverb')),
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
                                'Tap to select image',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          )
                          : null,
                ),
              ),
              SizedBox(height: 24),

              // Category selector
              StreamBuilder<List<Category>>(
                stream: _proverbService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data ?? [];

                  if (categories.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No categories available. Please add categories first.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        _selectedCategoryName =
                            categories
                                .firstWhere((cat) => cat.id == value)
                                .name;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 24),

              // Proverb text
              CustomTextField(
                controller: _textController,
                label: 'Proverb Text',
                hint: 'Enter the proverb text',
                maxLines: 3,
                validator:
                    (value) =>
                        Validators.validateRequired(value, 'Proverb text'),
              ),
              SizedBox(height: 24),

              // Author
              CustomTextField(
                controller: _authorController,
                label: 'Author',
                hint: 'Enter the author\'s name',
                validator:
                    (value) => Validators.validateRequired(value, 'Author'),
              ),
              SizedBox(height: 32),

              // Add button
              CustomButton(
                text: 'Add Proverb',
                isLoading: _isLoading,
                onPressed: _addProverb,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
