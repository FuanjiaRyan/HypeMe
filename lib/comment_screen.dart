import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/social_service.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String collectionPath;
  final String? postTitle;

  const CommentScreen({
    super.key,
    required this.postId,
    required this.collectionPath,
    this.postTitle,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final SocialService _socialService = SocialService();
  final ScrollController _scrollController = ScrollController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await _socialService.addComment(
        widget.postId,
        widget.collectionPath,
        _commentController.text.trim(),
      );

      _commentController.clear();

      // Scroll to bottom to show new comment
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment posted!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCommentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading comments: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: Colors.grey[600],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final commentData = comment.data() as Map<String, dynamic>;
                    final userName = commentData['userName'] as String? ?? 'Anonymous';
                    final userImageUrl = commentData['userImageUrl'] as String?;
                    final commentText = commentData['comment'] as String? ?? '';
                    final createdAt = commentData['createdAt'] as Timestamp?;
                    final userId = commentData['userId'] as String?;
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                    return _buildCommentItem(
                      userName: userName,
                      userImageUrl: userImageUrl,
                      commentText: commentText,
                      createdAt: createdAt,
                      isOwnComment: userId == currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: FirebaseAuth.instance.currentUser != null
                        ? null
                        : null,
                    child: FirebaseAuth.instance.currentUser != null
                        ? FutureBuilder<DocumentSnapshot>(
                            future: _getCurrentUserProfile(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                final imageUrl = data['profileImageUrl'] as String?;
                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Comment Input Field
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Post Button
                  IconButton(
                    onPressed: _isPosting ? null : _postComment,
                    icon: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Color(0xFF00B4FF),
                            size: 24,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getCommentsStream() {
    final parts = widget.collectionPath.split('/');
    CollectionReference commentsRef;

    if (parts.length == 1) {
      // Simple collection like 'posts'
      commentsRef = FirebaseFirestore.instance
          .collection(parts[0])
          .doc(widget.postId)
          .collection('comments');
    } else if (parts.length == 3) {
      // Subcollection like 'videos/{artistId}/vids'
      commentsRef = FirebaseFirestore.instance
          .collection(parts[0])
          .doc(parts[1])
          .collection(parts[2])
          .doc(widget.postId)
          .collection('comments');
    } else {
      throw Exception('Invalid collection path');
    }

    return commentsRef.orderBy('createdAt', descending: false).snapshots();
  }

  Future<DocumentSnapshot> _getCurrentUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Try artist collection first
    final artistDoc = await FirebaseFirestore.instance
        .collection('artist')
        .doc(userId)
        .get();

    if (artistDoc.exists) {
      return artistDoc;
    }

    // Try users collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return userDoc;
  }

  Widget _buildCommentItem({
    required String userName,
    String? userImageUrl,
    required String commentText,
    Timestamp? createdAt,
    required bool isOwnComment,
  }) {
    String timeAgo = 'Just now';
    if (createdAt != null) {
      final now = DateTime.now();
      final commentTime = createdAt.toDate();
      final difference = now.difference(commentTime);

      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isOwnComment ? const Color(0xFF00B4FF) : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: userImageUrl != null && userImageUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userImageUrl,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.orange[300]!,
                              Colors.green[300]!,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.orange[300]!,
                          Colors.green[300]!,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              color: isOwnComment
                                  ? const Color(0xFF00B4FF)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOwnComment) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B4FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  color: Color(0xFF00B4FF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        commentText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

