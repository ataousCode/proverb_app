import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:proverbs/models/category.dart';
import '../../models/proverb.dart';
import '../../services/proverb_service.dart';
import '../../widgets/common/error_dialog.dart';

class ManageProverbsScreen extends StatefulWidget {
  @override
  _ManageProverbsScreenState createState() => _ManageProverbsScreenState();
}

class _ManageProverbsScreenState extends State<ManageProverbsScreen> {
  final ProverbService _proverbService = ProverbService();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Proverbs'),
      ),
      body: Column(
        children: [
          // Category filter
          Padding(
            padding: EdgeInsets.all(16),
            child: StreamBuilder<List<Category>>(
              stream: _proverbService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data ?? [];
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedCategoryId,
                      isExpanded: true,
                      hint: Text('Filter by category'),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categories.map((category) {
                          return DropdownMenuItem<String?>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Proverbs list
          Expanded(
            child: _buildProverbsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProverbsList() {
    Stream<List<Proverb>> proverbsStream = _selectedCategoryId == null
        ? _proverbService.getProverbs()
        : _proverbService.getProverbsByCategory(_selectedCategoryId!);

    return StreamBuilder<List<Proverb>>(
      stream: proverbsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading proverbs: ${snapshot.error}'),
          );
        }

        final proverbs = snapshot.data ?? [];

        if (proverbs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.format_quote,
                  size: 60,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No proverbs found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: proverbs.length,
          itemBuilder: (context, index) {
            final proverb = proverbs[index];
            return _buildProverbItem(proverb);
          },
        );
      },
    );
  }

  Widget _buildProverbItem(Proverb proverb) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Proverb image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: proverb.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Proverb details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proverb.text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'By: ${proverb.author}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      proverb.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(proverb),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(proverb),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Proverb proverb) {
    // Navigate to edit screen or show a modal
    // For simplicity, just showing a basic dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Proverb'),
        content: Text(
          'This functionality will be implemented in the next release.',
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

  void _showDeleteDialog(Proverb proverb) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Proverb'),
        content: Text(
          'Are you sure you want to delete this proverb? This action cannot be undone.',
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
              _deleteProverb(proverb);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProverb(Proverb proverb) async {
    try {
      await _proverbService.deleteProverb(proverb.id, proverb.imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proverb deleted successfully')),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: e.toString()),
      );
    }
  }
}