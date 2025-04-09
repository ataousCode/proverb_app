// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/proverb.dart';
import '../../services/user_prefs_service.dart';
import '../../widgets/proverb/proverb_actions.dart';
import '../../services/proverb_service.dart';

class ProverbDetailScreen extends StatelessWidget {
  final Proverb proverb;
  final UserPrefsService _userPrefsService = UserPrefsService();
  final ProverbService _proverbService = ProverbService();

  ProverbDetailScreen({super.key, required this.proverb});

  @override
  Widget build(BuildContext context) {
    // Mark proverb as read when viewed
    _userPrefsService.markAsRead(proverb.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image background
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  proverb.categoryName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: proverb.imageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.error),
                    ),
              ),
            ),
          ),

          // Proverb content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Proverb text
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        SizedBox(height: 8),
                        Text(
                          proverb.text,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '- ${proverb.author}',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  ProverbActions(proverbId: proverb.id),
                  SizedBox(height: 32),
                  Text(
                    'More from this category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildRelatedProverbs(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProverbs(BuildContext context) {
    return StreamBuilder<List<Proverb>>(
      stream: _proverbService.getProverbsByCategory(proverb.categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading related proverbs'));
        }

        final proverbsList = snapshot.data ?? [];

        // Filter out the current proverb
        final relatedProverbs =
            proverbsList.where((p) => p.id != proverb.id).take(3).toList();

        if (relatedProverbs.isEmpty) {
          return Center(
            child: Text(
              'No other proverbs in this category yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return Container(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProverbs.length,
            itemBuilder: (context, index) {
              final relatedProverb = relatedProverbs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProverbDetailScreen(proverb: relatedProverb),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        relatedProverb.imageUrl,
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          relatedProverb.text,
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '- ${relatedProverb.author}',
                          style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
