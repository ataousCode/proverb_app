import 'package:flutter/material.dart';
import '../../services/user_prefs_service.dart';

class ProverbActions extends StatelessWidget {
  final String proverbId;
  final UserPrefsService userPrefsService = UserPrefsService();

  ProverbActions({
    required this.proverbId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: userPrefsService.getUserProverbPrefs(proverbId),
      builder: (context, snapshot) {
        final prefs = snapshot.data ?? {
          'isFavorite': false,
          'isRead': true,
          'isDisliked': false,
        };
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              icon: prefs['isFavorite']
                  ? Icons.favorite
                  : Icons.favorite_border,
              label: prefs['isFavorite']
                  ? 'Favorited'
                  : 'Favorite',
              color: prefs['isFavorite']
                  ? Colors.red
                  : Colors.grey,
              onTap: () {
                userPrefsService.toggleFavorite(
                  proverbId,
                  !prefs['isFavorite'],
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.share,
              label: 'Share',
              color: Colors.blue,
              onTap: () {
                // Share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sharing coming soon')),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: prefs['isDisliked']
                  ? Icons.thumb_down
                  : Icons.thumb_down_outlined,
              label: prefs['isDisliked']
                  ? 'Disliked'
                  : 'Dislike',
              color: prefs['isDisliked']
                  ? Colors.orange
                  : Colors.grey,
              onTap: () {
                userPrefsService.toggleDislike(
                  proverbId,
                  !prefs['isDisliked'],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}