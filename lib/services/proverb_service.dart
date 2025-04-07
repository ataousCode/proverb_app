import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/proverb.dart';
import '../models/category.dart';
import 'storage_service.dart';

class ProverbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();
  final _uuid = Uuid();

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Check if user exists and has permissions
  Future<bool> _checkUserPermissions() async {
    if (_currentUserId == null) return false;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUserId).get();

      return userDoc.exists;
    } catch (e) {
      print('Error checking user permissions: $e');
      return false;
    }
  }

  // Get all proverbs (filtered by admin for admin users)
  // Stream<List<Proverb>> getProverbs() {
  //   // First check if we have a user
  //   if (_currentUserId == null) {
  //     // Return empty list if not authenticated
  //     return Stream.value([]);
  //   }

  //   // First get the user document to check if they're an admin
  //   return _firestore
  //       .collection('users')
  //       .doc(_currentUserId)
  //       .snapshots()
  //       .asyncMap((userSnapshot) async {
  //         bool isAdmin = userSnapshot.data()?['isAdmin'] ?? false;

  //         // Now fetch the appropriate proverbs based on user type
  //         if (isAdmin) {
  //           // For admin users, get only their own proverbs
  //           final proverbsSnapshot =
  //               await _firestore
  //                   .collection('proverbs')
  //                   .where('createdBy', isEqualTo: _currentUserId)
  //                   .orderBy('createdAt', descending: true)
  //                   .get();

  //           return proverbsSnapshot.docs.map((doc) {
  //             return Proverb.fromFirestore(doc.data(), doc.id);
  //           }).toList();
  //         } else {
  //           // For regular users, get all proverbs
  //           final proverbsSnapshot =
  //               await _firestore
  //                   .collection('proverbs')
  //                   .orderBy('createdAt', descending: true)
  //                   .get();

  //           return proverbsSnapshot.docs.map((doc) {
  //             return Proverb.fromFirestore(doc.data(), doc.id);
  //           }).toList();
  //         }
  //       });
  // }
  Stream<List<Proverb>> getProverbs() {
    // First check if we have a user
    if (_currentUserId == null) {
      // Return empty list if not authenticated
      return Stream.value([]);
    }

    // Simple query without ordering
    return _firestore.collection('proverbs').snapshots().map((snapshot) {
      List<Proverb> proverbs =
          snapshot.docs.map((doc) {
            return Proverb.fromFirestore(doc.data(), doc.id);
          }).toList();

      // Sort in memory instead of in the query
      proverbs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return proverbs;
    });
  }

  // Get proverbs by category (filtered by admin for admin users)
  // Stream<List<Proverb>> getProverbsByCategory(String categoryId) {
  //   // First check if we have a user
  //   if (_currentUserId == null) {
  //     // Return empty list if not authenticated
  //     return Stream.value([]);
  //   }

  //   // First get the user document to check if they're an admin
  //   return _firestore
  //       .collection('users')
  //       .doc(_currentUserId)
  //       .snapshots()
  //       .asyncMap((userSnapshot) async {
  //         bool isAdmin = userSnapshot.data()?['isAdmin'] ?? false;

  //         // Now fetch the appropriate proverbs based on user type
  //         if (isAdmin) {
  //           // For admin users, get only their own proverbs in this category
  //           final proverbsSnapshot =
  //               await _firestore
  //                   .collection('proverbs')
  //                   .where('categoryId', isEqualTo: categoryId)
  //                   .where('createdBy', isEqualTo: _currentUserId)
  //                   .orderBy('createdAt', descending: true)
  //                   .get();

  //           return proverbsSnapshot.docs.map((doc) {
  //             return Proverb.fromFirestore(doc.data(), doc.id);
  //           }).toList();
  //         } else {
  //           // For regular users, get all proverbs in this category
  //           final proverbsSnapshot =
  //               await _firestore
  //                   .collection('proverbs')
  //                   .where('categoryId', isEqualTo: categoryId)
  //                   .orderBy('createdAt', descending: true)
  //                   .get();

  //           return proverbsSnapshot.docs.map((doc) {
  //             return Proverb.fromFirestore(doc.data(), doc.id);
  //           }).toList();
  //         }
  //       });
  // }
  Stream<List<Proverb>> getProverbsByCategory(String categoryId) {
    // First check if we have a user
    if (_currentUserId == null) {
      // Return empty list if not authenticated
      return Stream.value([]);
    }

    // Simple query with only where, no ordering
    return _firestore
        .collection('proverbs')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          List<Proverb> proverbs =
              snapshot.docs.map((doc) {
                return Proverb.fromFirestore(doc.data(), doc.id);
              }).toList();

          // Sort in memory instead of in the query
          proverbs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return proverbs;
        });
  }

  // Get all categories (shared among all admins)
  Stream<List<Category>> getCategories() {
    // Error handling to prevent the errors shown in screenshots
    try {
      return _firestore
          .collection('categories')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return Category.fromFirestore(doc.data(), doc.id);
            }).toList();
          })
          .handleError((error) {
            print('Error getting categories: $error');
            return [];
          });
    } catch (e) {
      print('Exception getting categories: $e');
      return Stream.value([]);
    }
  }

  // Add a new proverb
  Future<void> addProverb(
    String text,
    String author,
    File imageFile,
    String categoryId,
    String categoryName,
  ) async {
    try {
      // Check user permissions
      bool hasPermission = await _checkUserPermissions();
      if (!hasPermission) {
        throw 'You do not have permission to add proverbs';
      }

      // Upload image to storage
      String fileName = 'proverbs/${_uuid.v4()}.jpg';
      String imageUrl = await _storageService.uploadFile(imageFile, fileName);

      // Get category reference to ensure it exists
      DocumentSnapshot categoryDoc =
          await _firestore.collection('categories').doc(categoryId).get();

      if (!categoryDoc.exists) {
        throw 'Category does not exist';
      }

      // Add proverb to Firestore
      await _firestore.collection('proverbs').add({
        'text': text,
        'author': author,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'createdBy': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to add proverb: $e';
    }
  }

  // Update a proverb
  Future<void> updateProverb(
    String id,
    String text,
    String author,
    File? imageFile,
    String categoryId,
    String categoryName,
  ) async {
    try {
      // Check user permissions and ownership
      DocumentSnapshot proverbDoc =
          await _firestore.collection('proverbs').doc(id).get();

      if (!proverbDoc.exists) {
        throw 'Proverb does not exist';
      }

      Map<String, dynamic> proverbData =
          proverbDoc.data() as Map<String, dynamic>;
      if (proverbData['createdBy'] != _currentUserId) {
        throw 'You do not have permission to edit this proverb';
      }

      Map<String, dynamic> data = {
        'text': text,
        'author': author,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If a new image is provided, upload it
      if (imageFile != null) {
        String fileName = 'proverbs/${_uuid.v4()}.jpg';
        String imageUrl = await _storageService.uploadFile(imageFile, fileName);
        data['imageUrl'] = imageUrl;
      }

      await _firestore.collection('proverbs').doc(id).update(data);
    } catch (e) {
      throw 'Failed to update proverb: $e';
    }
  }

  // Delete a proverb
  Future<void> deleteProverb(String id, String imageUrl) async {
    try {
      // Check user permissions and ownership
      DocumentSnapshot proverbDoc =
          await _firestore.collection('proverbs').doc(id).get();

      if (!proverbDoc.exists) {
        throw 'Proverb does not exist';
      }

      Map<String, dynamic> proverbData =
          proverbDoc.data() as Map<String, dynamic>;
      if (proverbData['createdBy'] != _currentUserId) {
        throw 'You do not have permission to delete this proverb';
      }

      // Delete the image from storage
      if (imageUrl.isNotEmpty) {
        await _storageService.deleteFile(imageUrl);
      }

      // Delete the proverb from Firestore
      await _firestore.collection('proverbs').doc(id).delete();
    } catch (e) {
      throw 'Failed to delete proverb: $e';
    }
  }

  // Add a new category (shared among all admins)
  Future<void> addCategory(String name, File imageFile) async {
    try {
      // Check if user is admin
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUserId).get();

      if (!userDoc.exists ||
          !(userDoc.data() as Map<String, dynamic>)['isAdmin']) {
        throw 'Only admin users can add categories';
      }

      // Check if category with same name already exists
      QuerySnapshot existingCategories =
          await _firestore
              .collection('categories')
              .where('name', isEqualTo: name)
              .get();

      if (existingCategories.docs.isNotEmpty) {
        throw 'A category with this name already exists';
      }

      // Upload image to storage
      String fileName = 'categories/${_uuid.v4()}.jpg';
      String imageUrl = await _storageService.uploadFile(imageFile, fileName);

      // Add category to Firestore
      await _firestore.collection('categories').add({
        'name': name,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _currentUserId,
      });
    } catch (e) {
      throw 'Failed to add category: $e';
    }
  }

//   Future<String> uploadFile(File file, String path) async {
//   try {
//     // Create storage reference
//     final ref = _storage.ref().child(path);
    
//     // Add metadata to help with permissions
//     final metadata = SettableMetadata(
//       contentType: 'image/jpeg',
//     );
    
//     // Upload the file with metadata
//     await ref.putFile(file, metadata);
    
//     // Get and return the download URL
//     return await ref.getDownloadURL();
//   } on FirebaseException catch (e) {
//     if (e.code == 'unauthorized') {
//       print('Storage permission error: $e');
//       throw 'You do not have permission to upload files. Please check your account permissions.';
//     } else {
//       throw 'Failed to upload file: ${e.message}';
//     }
//   } catch (e) {
//     throw 'Failed to upload file: $e';
//   }
// }

  // Delete a category
  Future<void> deleteCategory(String id, String imageUrl) async {
    try {
      // Check if user is admin
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUserId).get();

      if (!userDoc.exists ||
          !(userDoc.data() as Map<String, dynamic>)['isAdmin']) {
        throw 'Only admin users can delete categories';
      }

      // Delete the image from storage
      if (imageUrl.isNotEmpty) {
        await _storageService.deleteFile(imageUrl);
      }

      // Delete the category from Firestore
      await _firestore.collection('categories').doc(id).delete();

      // Optional: Update or delete proverbs in this category
      // This could be done with a Cloud Function for better reliability
    } catch (e) {
      throw 'Failed to delete category: $e';
    }
  }
}
