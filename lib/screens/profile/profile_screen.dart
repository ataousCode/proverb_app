// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_dialog.dart';
import '../../utils/helpers.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: FutureBuilder(
        future: authService.getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            // Handle no user - should redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _forceSignOut(context);
            });

            return Center(child: Text('User not found. Please login again.'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // Profile avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  user.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (user.isAdmin)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 40),

                // Settings options
                _buildSettingsItem(
                  context,
                  icon: Icons.favorite,
                  title: 'My Favorites',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoritesScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    Helpers.showSnackBar(
                      context,
                      'Notifications will be available in the next update',
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  onTap: () {
                    // This handles tap on the entire row
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                    Helpers.showSnackBar(
                      context,
                      'Theme change will be available in the next update',
                    );
                  },
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      Helpers.showSnackBar(
                        context,
                        'Theme change will be available in the next update',
                      );
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    Helpers.showSnackBar(
                      context,
                      'Language options will be available in the next update',
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Helpers.showSnackBar(
                      context,
                      'Help & Support will be available in the next update',
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                SizedBox(height: 40),

                // Logout button
                CustomButton(
                  text: 'Log Out',
                  isLoading: _isLoading,
                  onPressed: () => _signOut(context),
                  icon: Icons.logout,
                ),
                SizedBox(height: 16),

                // Delete account button
                TextButton(
                  onPressed: () => _showDeleteAccountDialog(context),
                  child: Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('About Proverbs App'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version: 1.0.0'),
                SizedBox(height: 8),
                Text(
                  'A beautiful app for exploring proverbs from around the world.',
                ),
                SizedBox(height: 16),
                Text(
                  'Made with ❤️ using Flutter and Firebase',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  // Updated sign out method
  Future<void> _signOut(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthService>().signOut(context);
      // No need to navigate here as it's handled in the service
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

  // Force sign out if user data can't be found
  Future<void> _forceSignOut(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut(context);

      // Show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session expired. Please login again.')),
      );
    } catch (e) {
      print('Error during force sign out: $e');
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
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
                  _deleteAccount(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.deleteAccount();
      // AuthWrapper will handle navigation
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
}
