import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'all_artist_post.dart';
import 'services/social_service.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String artistId;

  const ArtistProfileScreen({
    super.key,
    required this.artistId,
  });

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  final SocialService _socialService = SocialService();
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSocialData();
  }

  Future<void> _loadSocialData() async {
    try {
      _isFollowing = await _socialService.isFollowing(widget.artistId);
      _followersCount = await _socialService.getFollowerCount(widget.artistId);
      _followingCount = await _socialService.getFollowingCount(widget.artistId);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading social data: $e');
    }
  }

  Future<void> _handleFollow() async {
    try {
      if (_isFollowing) {
        await _socialService.unfollowArtist(widget.artistId);
        _isFollowing = false;
        _followersCount--;
      } else {
        await _socialService.followArtist(widget.artistId);
        _isFollowing = true;
        _followersCount++;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<QueryDocumentSnapshot>> _fetchAllPosts() async {
    List<QueryDocumentSnapshot> allPosts = [];

    try {
      // Fetch from posts collection (without orderBy to avoid index requirement)
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('artistId', isEqualTo: widget.artistId)
          .get();

      allPosts.addAll(postsSnapshot.docs);
    } catch (e) {
      print('Error fetching posts: $e');
      // Continue to try fetching videos even if posts fail
    }

    try {
      // Fetch from videos collection (vids subcollection)
      final videosDoc = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.artistId)
          .get();

      if (videosDoc.exists) {
        final vidsSnapshot = await videosDoc.reference
            .collection('vids')
            .get();

        allPosts.addAll(vidsSnapshot.docs);
      }
    } catch (e) {
      print('Error fetching videos: $e');
      // Continue even if videos fail
    }

    // Sort by createdAt (most recent first) - handle null timestamps
    allPosts.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTime = aData['createdAt'] as Timestamp?;
      final bTime = bData['createdAt'] as Timestamp?;
      
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      
      return bTime.compareTo(aTime);
    });

    return allPosts;
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
          'Artist Profile',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artist')
            .doc(widget.artistId)
            .snapshots(),
        builder: (context, artistSnapshot) {
          if (artistSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
              ),
            );
          }

          if (!artistSnapshot.hasData || !artistSnapshot.data!.exists) {
            return const Center(
              child: Text(
                'Artist not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final artistData = artistSnapshot.data!.data() as Map<String, dynamic>;
          final profileImageUrl = artistData['profileImageUrl'] as String?;
          final artistName = artistData['artistName'] as String? ?? 'Unknown Artist';
          final bio = artistData['bio'] as String? ?? '';
          final email = artistData['email'] as String? ?? '';

          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00B4FF),
                            width: 3,
                          ),
                        ),
                        child: profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: profileImageUrl,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
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
                                      size: 60,
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
                                  size: 60,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Artist Name
                      Text(
                        artistName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Followers and Following Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem('Followers', _followersCount),
                          const SizedBox(width: 32),
                          _buildStatItem('Following', _followingCount),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Follow Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? Colors.grey[700]
                                : const Color(0xFF00B4FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isFollowing ? 'Following' : 'Follow',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bio
                      if (bio.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bio,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Posts Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Posts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              // Posts Grid
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _fetchAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                          ),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading posts: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No posts yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }

                  final posts = snapshot.data!;

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          final postData = post.data() as Map<String, dynamic>;
                          final postUrl = postData['url'] as String? ?? postData['videoUrl'] as String? ?? '';
                          final postType = postData['type'] as String? ?? (postData['videoUrl'] != null ? 'video' : 'image');

                          return GestureDetector(
                            onTap: () {
                              // Navigate to post detail or play video
                              if (postType == 'video') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AllArtistPostScreen(showBackButton: true),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: postType == 'video' && postUrl.isNotEmpty
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: postUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.videocam,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    )
                                  : postUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: postUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.image,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.insert_drive_file,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                            ),
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

