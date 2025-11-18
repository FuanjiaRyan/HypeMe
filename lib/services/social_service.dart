import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID (works for both artists and regular users)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Follow an artist
  Future<void> followArtist(String artistId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');
    if (userId == artistId) throw Exception('Cannot follow yourself');

    final followRef = _firestore
        .collection('follows')
        .doc('$userId-$artistId');

    final followDoc = await followRef.get();

    if (!followDoc.exists) {
      await followRef.set({
        'followerId': userId,
        'followingId': artistId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update follower count for artist
      await _firestore.collection('artist').doc(artistId).update({
        'followers': FieldValue.increment(1),
      });

      // Update following count for current user
      // Check if user is artist or regular user
      final artistDoc = await _firestore.collection('artist').doc(userId).get();
      if (artistDoc.exists) {
        await _firestore.collection('artist').doc(userId).update({
          'following': FieldValue.increment(1),
        });
      } else {
        await _firestore.collection('users').doc(userId).update({
          'following': FieldValue.increment(1),
        });
      }
    }
  }

  /// Unfollow an artist
  Future<void> unfollowArtist(String artistId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final followRef = _firestore
        .collection('follows')
        .doc('$userId-$artistId');

    final followDoc = await followRef.get();

    if (followDoc.exists) {
      await followRef.delete();

      // Update follower count for artist
      await _firestore.collection('artist').doc(artistId).update({
        'followers': FieldValue.increment(-1),
      });

      // Update following count for current user
      final artistDoc = await _firestore.collection('artist').doc(userId).get();
      if (artistDoc.exists) {
        await _firestore.collection('artist').doc(userId).update({
          'following': FieldValue.increment(-1),
        });
      } else {
        await _firestore.collection('users').doc(userId).update({
          'following': FieldValue.increment(-1),
        });
      }
    }
  }

  /// Check if current user is following an artist
  Future<bool> isFollowing(String artistId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final followDoc = await _firestore
        .collection('follows')
        .doc('$userId-$artistId')
        .get();

    return followDoc.exists;
  }

  /// Like a post/video
  /// postId: The document ID of the post/video
  /// collectionPath: The path to the collection (e.g., 'videos/{artistId}/vids' or 'posts')
  Future<void> likePost(String postId, String collectionPath) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Parse collection path to get the document reference
    final parts = collectionPath.split('/');
    DocumentReference postRef;
    
    if (parts.length == 1) {
      // Simple collection like 'posts'
      postRef = _firestore.collection(parts[0]).doc(postId);
    } else if (parts.length == 3) {
      // Subcollection like 'videos/{artistId}/vids'
      postRef = _firestore
          .collection(parts[0])
          .doc(parts[1])
          .collection(parts[2])
          .doc(postId);
    } else {
      throw Exception('Invalid collection path');
    }

    final likeRef = postRef.collection('likes').doc(userId);
    final likeDoc = await likeRef.get();

    if (!likeDoc.exists) {
      await likeRef.set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update like count
      await postRef.update({
        'likes': FieldValue.increment(1),
      });
    }
  }

  /// Unlike a post/video
  Future<void> unlikePost(String postId, String collectionPath) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final parts = collectionPath.split('/');
    DocumentReference postRef;
    
    if (parts.length == 1) {
      postRef = _firestore.collection(parts[0]).doc(postId);
    } else if (parts.length == 3) {
      postRef = _firestore
          .collection(parts[0])
          .doc(parts[1])
          .collection(parts[2])
          .doc(postId);
    } else {
      throw Exception('Invalid collection path');
    }

    final likeRef = postRef.collection('likes').doc(userId);
    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      await likeRef.delete();

      // Update like count
      await postRef.update({
        'likes': FieldValue.increment(-1),
      });
    }
  }

  /// Check if current user has liked a post/video
  Future<bool> isLiked(String postId, String collectionPath) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final parts = collectionPath.split('/');
    DocumentReference postRef;
    
    if (parts.length == 1) {
      postRef = _firestore.collection(parts[0]).doc(postId);
    } else if (parts.length == 3) {
      postRef = _firestore
          .collection(parts[0])
          .doc(parts[1])
          .collection(parts[2])
          .doc(postId);
    } else {
      return false;
    }

    final likeDoc = await postRef.collection('likes').doc(userId).get();
    return likeDoc.exists;
  }

  /// Add a comment to a post/video
  Future<void> addComment(
    String postId,
    String collectionPath,
    String commentText,
  ) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final parts = collectionPath.split('/');
    DocumentReference postRef;
    
    if (parts.length == 1) {
      postRef = _firestore.collection(parts[0]).doc(postId);
    } else if (parts.length == 3) {
      postRef = _firestore
          .collection(parts[0])
          .doc(parts[1])
          .collection(parts[2])
          .doc(postId);
    } else {
      throw Exception('Invalid collection path');
    }

    // Get user info
    String userName = 'Anonymous';
    String? userImageUrl;
    
    final artistDoc = await _firestore.collection('artist').doc(userId).get();
    if (artistDoc.exists) {
      final data = artistDoc.data()!;
      userName = data['artistName'] as String? ?? 'Anonymous';
      userImageUrl = data['profileImageUrl'] as String?;
    } else {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        userName = data['fullName'] as String? ?? 'Anonymous';
        userImageUrl = data['profileImageUrl'] as String?;
      }
    }

    await postRef.collection('comments').add({
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'comment': commentText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update comment count
    await postRef.update({
      'comments': FieldValue.increment(1),
    });
  }

  /// Increment view count for a video
  Future<void> incrementView(String postId, String collectionPath) async {
    final userId = currentUserId;
    
    final parts = collectionPath.split('/');
    DocumentReference postRef;
    
    if (parts.length == 1) {
      postRef = _firestore.collection(parts[0]).doc(postId);
    } else if (parts.length == 3) {
      postRef = _firestore
          .collection(parts[0])
          .doc(parts[1])
          .collection(parts[2])
          .doc(postId);
    } else {
      throw Exception('Invalid collection path');
    }

    // Track views per user to avoid duplicate views
    if (userId != null) {
      final viewRef = postRef.collection('views').doc(userId);
      final viewDoc = await viewRef.get();
      
      if (!viewDoc.exists) {
        await viewRef.set({
          'userId': userId,
          'viewedAt': FieldValue.serverTimestamp(),
        });

        // Increment view count only if user hasn't viewed before
        await postRef.update({
          'views': FieldValue.increment(1),
        });
      }
    } else {
      // Anonymous view - just increment (less accurate but works)
      await postRef.update({
        'views': FieldValue.increment(1),
      });
    }
  }

  /// Get follower count for an artist
  Future<int> getFollowerCount(String artistId) async {
    final artistDoc = await _firestore.collection('artist').doc(artistId).get();
    if (artistDoc.exists) {
      final data = artistDoc.data()!;
      final count = (data['followers'] as int?) ?? 0;
      // If field doesn't exist, initialize it
      if (!data.containsKey('followers')) {
        await _firestore.collection('artist').doc(artistId).set({
          'followers': 0,
        }, SetOptions(merge: true));
      }
      return count;
    }
    return 0;
  }

  /// Get following count for an artist
  Future<int> getFollowingCount(String artistId) async {
    final artistDoc = await _firestore.collection('artist').doc(artistId).get();
    if (artistDoc.exists) {
      final data = artistDoc.data()!;
      final count = (data['following'] as int?) ?? 0;
      // If field doesn't exist, initialize it
      if (!data.containsKey('following')) {
        await _firestore.collection('artist').doc(artistId).set({
          'following': 0,
        }, SetOptions(merge: true));
      }
      return count;
    }
    return 0;
  }
}

