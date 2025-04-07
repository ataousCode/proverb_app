import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proverbs/models/eview.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get user reviews
  Stream<List<Review>> getUserReviews() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    // Use a simple query with only one where clause
    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          List<Review> reviews =
              snapshot.docs.map((doc) {
                return Review.fromFirestore(doc.data(), doc.id);
              }).toList();

          // Sort in memory instead of using orderBy in the query
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return reviews;
        });
  }

  // Add a review
  Future<void> addReview(String text, int rating) async {
    if (_currentUserId == null) {
      throw 'You must be logged in to add a review';
    }

    await _firestore.collection('reviews').add({
      'userId': _currentUserId,
      'text': text,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    if (_currentUserId == null) {
      throw 'You must be logged in to delete a review';
    }

    // Check if the review belongs to the current user
    DocumentSnapshot reviewDoc =
        await _firestore.collection('reviews').doc(reviewId).get();

    if (!reviewDoc.exists) {
      throw 'Review does not exist';
    }

    Map<String, dynamic> reviewData = reviewDoc.data() as Map<String, dynamic>;
    if (reviewData['userId'] != _currentUserId) {
      throw 'You can only delete your own reviews';
    }

    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  // Get app average rating
  Future<double> getAppAverageRating() async {
    try {
      QuerySnapshot reviewsSnapshot =
          await _firestore.collection('reviews').get();

      if (reviewsSnapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'] ?? 0;
      }

      return totalRating / reviewsSnapshot.docs.length;
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }
}
