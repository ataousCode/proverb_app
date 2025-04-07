import 'package:flutter/material.dart';
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
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard.dart';
import 'proverb_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProverbService _proverbService = ProverbService();
  final UserPrefsService _userPrefsService = UserPrefsService();
  String? _selectedCategoryId;
  UserModel? _currentUser;
  int _currentIndex = 0;
  bool _viewAsList = true; // Toggle between list and swiper view

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Proverbs' : 'Favorites'),
        actions: [
          // View toggle button
          IconButton(
            icon: Icon(_viewAsList ? Icons.view_carousel : Icons.view_list),
            onPressed: () {
              setState(() {
                _viewAsList = !_viewAsList;
              });
            },
          ),
          if (_currentUser?.isAdmin == true)
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboard()),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories horizontal list - only show on Proverbs tab
          if (_currentIndex == 0) _buildCategoriesList(),

          // Proverbs list (main content)
          Expanded(
            child:
                _currentIndex == 0
                    ? _buildProverbsContent()
                    : _buildFavoritesContent(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Proverbs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
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

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Could not load data. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // Just setting state will rebuild and retry
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
