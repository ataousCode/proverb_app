import 'package:flutter/material.dart';
import '../../models/proverb.dart';
import '../../services/proverb_service.dart';
import '../../services/user_prefs_service.dart';
import '../../widgets/proverb/proverb_card.dart';
import '../home/proverb_detail_screen.dart';
import '../../widgets/common/loading_indicator.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ProverbService _proverbService = ProverbService();
  final UserPrefsService _userPrefsService = UserPrefsService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites'),
      ),
      body: StreamBuilder<List<String>>(
        stream: _userPrefsService.getFavoriteProverbIds(),
        builder: (context, favSnapshot) {
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator(message: 'Loading your favorites...');
          }

          final favoriteIds = favSnapshot.data ?? [];

          if (favoriteIds.isEmpty) {
            return _buildEmptyState();
          }

          return StreamBuilder<List<Proverb>>(
            stream: _proverbService.getProverbs(),
            builder: (context, proverbsSnapshot) {
              if (proverbsSnapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }

              final allProverbs = proverbsSnapshot.data ?? [];
              final favoriteProverbs = allProverbs
                  .where((proverb) => favoriteIds.contains(proverb.id))
                  .toList();

              if (favoriteProverbs.isEmpty) {
                return _buildEmptyState();
              }

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
                          builder: (context) => ProverbDetailScreen(proverb: proverb),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon on proverbs you like',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.format_quote),
            label: Text('Explore Proverbs'),
          ),
        ],
      ),
    );
  }
}