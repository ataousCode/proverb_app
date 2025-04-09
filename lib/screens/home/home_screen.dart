// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:proverbs/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/proverb.dart';
import '../../models/category.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/proverb_service.dart';
import '../../services/user_prefs_service.dart';
import '../../widgets/proverb/proverb_card.dart';
import '../../widgets/proverb/proverb_swiper.dart';
import '../admin/admin_dashboard.dart';
import '../profile/profile_screen.dart';
import 'proverb_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProverbService _proverbService = ProverbService();
  final UserPrefsService _userPrefsService = UserPrefsService();
  String? _selectedCategoryId;
  UserModel? _currentUser;
  int _currentIndex = 0;
  bool _viewAsList = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    UserModel? user = await context.read<AuthService>().getUserDetails();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      // Redirect to login on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      });
      // Show loading while redirecting
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          // View toggle button - only show on Proverbs tab
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(_viewAsList ? Icons.view_carousel : Icons.view_list),
              onPressed: () {
                setState(() {
                  _viewAsList = !_viewAsList;
                });
              },
            ),
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'logout') {
                _signOut(context);
              }
            },
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Proverbs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          // Only show admin dashboard tab for admin users
          if (_currentUser?.isAdmin == true)
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Dashboard',
            ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Proverbs';
      case 1:
        return 'Favorites';
      case 2:
        return 'Profile';
      case 3:
        // Only shown for admin users
        return 'Admin Dashboard';
      default:
        return 'Proverbs App';
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildProverbsTab();
      case 1:
        return _buildFavoritesTab();
      case 2:
        return ProfileScreen();
      case 3:
        // Only shown for admin users
        if (_currentUser?.isAdmin == true) {
          return AdminDashboard();
        } else {
          return _buildProverbsTab();
        }
      default:
        return _buildProverbsTab();
    }
  }

  Widget _buildProverbsTab() {
    return Column(
      children: [
        _buildCategoriesList(),
        Expanded(child: _buildProverbsContent()),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return _buildFavoritesContent();
  }

  Widget _buildCategoriesList() {
    return Container(
      height: 120,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: StreamBuilder<List<Category>>(
        stream: _proverbService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading categories'));
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(child: Text('No categories available'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 for "All" category
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" category
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color:
                          _selectedCategoryId == null
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category,
                          color:
                              _selectedCategoryId == null
                                  ? Colors.white
                                  : Colors.grey[700],
                          size: 32,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All',
                          style: TextStyle(
                            color:
                                _selectedCategoryId == null
                                    ? Colors.white
                                    : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final category = categories[index - 1];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        _selectedCategoryId == category.id
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image:
                        category.imageUrl.isNotEmpty
                            ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                category.imageUrl,
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken,
                              ),
                            )
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProverbsContent() {
    Stream<List<Proverb>> proverbsStream =
        _selectedCategoryId == null
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
                Icon(Icons.format_quote, size: 60, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No proverbs available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Switch between list view and swiper view
        if (_viewAsList) {
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: proverbs.length,
            itemBuilder: (context, index) {
              final proverb = proverbs[index];
              return ProverbCard(
                proverb: proverb,
                onTap: () {
                  // Mark as read when tapped
                  _userPrefsService.markAsRead(proverb.id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProverbDetailScreen(proverb: proverb),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return ProverbSwiper(proverbs: proverbs);
        }
      },
    );
  }

  Widget _buildFavoritesContent() {
    return StreamBuilder<List<String>>(
      stream: _userPrefsService.getFavoriteProverbIds(),
      builder: (context, favSnapshot) {
        if (favSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final favoriteIds = favSnapshot.data ?? [];

        if (favoriteIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the heart icon on proverbs you like',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<List<Proverb>>(
          stream: _proverbService.getProverbs(),
          builder: (context, proverbsSnapshot) {
            if (proverbsSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final allProverbs = proverbsSnapshot.data ?? [];
            final favoriteProverbs =
                allProverbs
                    .where((proverb) => favoriteIds.contains(proverb.id))
                    .toList();

            if (_viewAsList) {
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: favoriteProverbs.length,
                itemBuilder: (context, index) {
                  final proverb = favoriteProverbs[index];
                  return ProverbCard(
                    proverb: proverb,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProverbDetailScreen(proverb: proverb),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return ProverbSwiper(proverbs: favoriteProverbs);
            }
          },
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }
}
