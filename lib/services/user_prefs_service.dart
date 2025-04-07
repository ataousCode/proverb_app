import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPrefsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mark proverb as favorite
  Future<void> toggleFavorite(String proverbId, bool isFavorite) async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentReference userProverbRef = _firestore
          .collection('userPrefs')
          .doc(userId)
          .collection('proverbs')
          .doc(proverbId);

      DocumentSnapshot doc = await userProverbRef.get();
      if (doc.exists) {
        await userProverbRef.update({'isFavorite': isFavorite});
      } else {
        await userProverbRef.set({
          'isFavorite': isFavorite,
          'isRead': true,
          'isDisliked': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to update favorite status: $e';
    }
  }

  // Mark proverb as read
  Future<void> markAsRead(String proverbId) async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentReference userProverbRef = _firestore
          .collection('userPrefs')
          .doc(userId)
          .collection('proverbs')
          .doc(proverbId);

      DocumentSnapshot doc = await userProverbRef.get();
      if (doc.exists) {
        await userProverbRef.update({'isRead': true});
      } else {
        await userProverbRef.set({
          'isFavorite': false,
          'isRead': true,
          'isDisliked': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to mark as read: $e';
    }
  }

  // Mark proverb as disliked
  Future<void> toggleDislike(String proverbId, bool isDisliked) async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentReference userProverbRef = _firestore
          .collection('userPrefs')
          .doc(userId)
          .collection('proverbs')
          .doc(proverbId);

      DocumentSnapshot doc = await userProverbRef.get();
      if (doc.exists) {
        await userProverbRef.update({'isDisliked': isDisliked});
      } else {
        await userProverbRef.set({
          'isFavorite': false,
          'isRead': true,
          'isDisliked': isDisliked,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to update dislike status: $e';
    }
  }

  // Get user preferences for a proverb
  Stream<Map<String, dynamic>> getUserProverbPrefs(String proverbId) {
    try {
      String userId = _auth.currentUser!.uid;
      return _firestore
          .collection('userPrefs')
          .doc(userId)
          .collection('proverbs')
          .doc(proverbId)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists) {
              return snapshot.data() as Map<String, dynamic>;
            } else {
              return {
                'isFavorite': false,
                'isRead': false,
                'isDisliked': false,
              };
            }
          });
    } catch (e) {
      print('Error getting user proverb preferences: $e');
      return Stream.value({
        'isFavorite': false,
        'isRead': false,
        'isDisliked': false,
      });
    }
  }

  // Get favorite proverbs
  Stream<List<String>> getFavoriteProverbIds() {
    try {
      String userId = _auth.currentUser!.uid;
      return _firestore
          .collection('userPrefs')
          .doc(userId)
          .collection('proverbs')
          .where('isFavorite', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => doc.id).toList();
          });
    } catch (e) {
      print('Error getting favorite proverbs: $e');
      return Stream.value([]);
    }
  }
}
