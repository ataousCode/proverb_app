import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import '../../models/proverb.dart';
import '../../services/user_prefs_service.dart';
import '../../screens/home/proverb_detail_screen.dart';

class ProverbSwiper extends StatelessWidget {
  final List<Proverb> proverbs;
  final UserPrefsService userPrefsService = UserPrefsService();

  ProverbSwiper({required this.proverbs});

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemCount: proverbs.length,
      itemBuilder: (context, index) {
        final proverb = proverbs[index];
        return GestureDetector(
          onTap: () {
            userPrefsService.markAsRead(proverb.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProverbDetailScreen(proverb: proverb),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(proverb.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 16),
                    Text(
                      proverb.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Text(
                      '- ${proverb.author}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    
                    // Action row at bottom
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: StreamBuilder<Map<String, dynamic>>(
                          stream: userPrefsService.getUserProverbPrefs(proverb.id),
                          builder: (context, snapshot) {
                            final prefs = snapshot.data ?? {
                              'isFavorite': false,
                              'isRead': false,
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
                                  color: prefs['isFavorite']
                                      ? Colors.red
                                      : Colors.white,
                                  onTap: () {
                                    userPrefsService.toggleFavorite(
                                      proverb.id,
                                      !prefs['isFavorite'],
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  context,
                                  icon: Icons.share,
                                  color: Colors.white,
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
                                  color: prefs['isDisliked']
                                      ? Colors.orange
                                      : Colors.white,
                                  onTap: () {
                                    userPrefsService.toggleDislike(
                                      proverb.id,
                                      !prefs['isDisliked'],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      pagination: SwiperPagination(
        builder: DotSwiperPaginationBuilder(
          activeColor: Theme.of(context).primaryColor,
          color: Colors.white,
        ),
      ),
      control: SwiperControl(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}