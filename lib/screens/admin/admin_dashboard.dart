import 'package:flutter/material.dart';
import '../../services/proverb_service.dart';
import '../../utils/helpers.dart';
import 'add_proverb_screen.dart';
import 'manage_proverbs_screen.dart';
import 'add_category_screen.dart';
import 'manage_categories_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ProverbService _proverbService = ProverbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin greeting
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your proverbs application',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Statistics section
            Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Stats cards
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Proverbs',
                  icon: Icons.format_quote,
                  color: Colors.blue,
                  stream: _proverbService.getProverbs().map(
                    (list) => list.length,
                  ),
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'Categories',
                  icon: Icons.category,
                  color: Colors.orange,
                  stream: _proverbService.getCategories().map(
                    (list) => list.length,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Actions section
            Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Action buttons
            Expanded(
              child: ListView(
                children: [
                  _buildActionButton(
                    context,
                    title: 'Add New Proverb',
                    description: 'Create a new proverb with image',
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProverbScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    title: 'Manage Proverbs',
                    description: 'Edit or delete existing proverbs',
                    icon: Icons.edit,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageProverbsScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    title: 'Add New Category',
                    description: 'Create a new category for proverbs',
                    icon: Icons.add_box_outlined,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategoryScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    title: 'Manage Categories',
                    description: 'Edit or delete existing categories',
                    icon: Icons.category,
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCategoriesScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    title: 'User Analytics',
                    description: 'View user activity and preferences',
                    icon: Icons.analytics_outlined,
                    color: Colors.teal,
                    onTap: () {
                      Helpers.showSnackBar(
                        context,
                        'Analytics will be available in the next update',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Stream<int> stream,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 12),
              Text(title, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 4),
              StreamBuilder<int>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      '...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  return Text(
                    '${snapshot.data ?? 0}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
