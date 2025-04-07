import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/category.dart';
import '../../services/proverb_service.dart';
import '../../widgets/common/error_dialog.dart';
import 'add_category_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final ProverbService _proverbService = ProverbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Categories')),
      body: StreamBuilder<List<Category>>(
        stream: _proverbService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading categories: ${snapshot.error}'),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No categories available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddCategory(),
                    icon: Icon(Icons.add),
                    label: Text('Add Category'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '${categories.length} Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCategory(),
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: CachedNetworkImageProvider(category.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Category info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () => _editCategory(category),
                    tooltip: 'Edit',
                    constraints: BoxConstraints.tightFor(width: 36, height: 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteDialog(category),
                    tooltip: 'Delete',
                    constraints: BoxConstraints.tightFor(width: 36, height: 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryScreen()),
    );
  }

  void _editCategory(Category category) {
    // For simplicity in this implementation, we'll just show a dialog
    // In a real app, you would navigate to an edit screen
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Category'),
            content: Text(
              'Category editing functionality will be available in the next update.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.name}"? This will also delete all proverbs in this category.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCategory(category);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await _proverbService.deleteCategory(category.id, category.imageUrl);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category deleted successfully')));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: e.toString()),
      );
    }
  }
}
