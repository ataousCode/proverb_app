import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/proverb.dart';
import '../../services/user_prefs_service.dart';

class ProverbCard extends StatelessWidget {
  final Proverb proverb;
  final Function onTap;
  final UserPrefsService userPrefsService = UserPrefsService();

  ProverbCard({required this.proverb, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proverb image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: proverb.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.error,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),

            // Proverb content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proverb.text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '- ${proverb.author}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
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
                  SizedBox(height: 12),

                  // Action buttons
                  StreamBuilder<Map<String, dynamic>>(
                    stream: userPrefsService.getUserProverbPrefs(proverb.id),
                    builder: (context, snapshot) {
                      final prefs =
                          snapshot.data ??
                          {
                            'isFavorite': false,
                            'isRead': false,
                            'isDisliked': false,
                          };

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              prefs['isFavorite']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  prefs['isFavorite']
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              userPrefsService.toggleFavorite(
                                proverb.id,
                                !prefs['isFavorite'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              prefs['isDisliked']
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_outlined,
                              color:
                                  prefs['isDisliked']
                                      ? Colors.orange
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              userPrefsService.toggleDislike(
                                proverb.id,
                                !prefs['isDisliked'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              prefs['isRead']
                                  ? Icons.visibility
                                  : Icons.visibility_outlined,
                              color:
                                  prefs['isRead']
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              userPrefsService.markAsRead(proverb.id);
                            },
                          ),
                        ],
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
}
