import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'artist_profile.dart';
import 'services/social_service.dart';
import 'comment_screen.dart';

class AllArtistPostScreen extends StatefulWidget {
  final bool? _showBackButton;

  const AllArtistPostScreen({super.key, bool? showBackButton})
    : _showBackButton = showBackButton;

  bool get showBackButton => _showBackButton ?? true;

  @override
  State<AllArtistPostScreen> createState() => _AllArtistPostScreenState();
}

class _AllArtistPostScreenState extends State<AllArtistPostScreen> {
  int _currentVideoIndex = 0;
  List<Map<String, dynamic>> _videos = [];
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  late PageController _pageController;
  final SocialService _socialService = SocialService();
  Map<String, bool> _likedVideos = {}; // videoId -> isLiked
  Map<String, bool> _followingArtists = {}; // artistId -> isFollowing
  Map<String, String> _videoCollectionPaths = {}; // videoId -> collectionPath

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadVideos();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    try {
      // Fetch all documents from 'videos' collection
      final videosSnapshot =
          await FirebaseFirestore.instance.collection('videos').get();

      List<Map<String, dynamic>> allVideos = [];

      // For each document in 'videos', get all documents from 'vids' subcollection
      for (var videoDoc in videosSnapshot.docs) {
        final vidsSnapshot =
            await videoDoc.reference
                .collection('vids')
                .orderBy('createdAt', descending: true)
                .get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          final videoId = vidDoc.id;
          final artistId = data['artistId'] ?? videoDoc.id;
          final collectionPath = 'videos/$artistId/vids';

          allVideos.add({
            'id': videoId,
            'videoUrl': data['videoUrl'] ?? data['url'] ?? '',
            'title': data['title'] ?? 'Untitled',
            'artistName': data['artistName'] ?? 'Unknown Artist',
            'artistId': artistId,
            'profileImageUrl': data['profileImageUrl'],
            'likes': data['likes'] ?? 0,
            'views': data['views'] ?? 0,
            'comments': data['comments'] ?? 0,
            'createdAt': data['createdAt'],
          });

          // Store collection path for this video
          _videoCollectionPaths[videoId] = collectionPath;
        }
      }

      if (mounted) {
        setState(() {
          _videos = allVideos;
          _isLoading = false;
        });

        if (_videos.isNotEmpty) {
          _initializeVideo(0);
          // Load like and follow states
          _loadSocialStates();
          // Jump to the first page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
          });
        }
      }
    } catch (e) {
      print('Error loading videos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSocialStates() async {
    // Load like states for all videos
    for (var video in _videos) {
      final videoId = video['id'] as String;
      final collectionPath = _videoCollectionPaths[videoId];
      if (collectionPath != null) {
        try {
          final isLiked = await _socialService.isLiked(videoId, collectionPath);
          _likedVideos[videoId] = isLiked;
        } catch (e) {
          print('Error loading like state: $e');
        }
      }
    }

    // Load follow states for all unique artists
    final uniqueArtists = _videos.map((v) => v['artistId'] as String).toSet();
    for (var artistId in uniqueArtists) {
      try {
        final isFollowing = await _socialService.isFollowing(artistId);
        _followingArtists[artistId] = isFollowing;
      } catch (e) {
        print('Error loading follow state: $e');
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (index < 0 || index >= _videos.length) return;

    _videoController?.dispose();

    final videoUrl = _videos[index]['videoUrl'] as String;
    if (videoUrl.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();

    // Track view
    final videoId = _videos[index]['id'] as String;
    final collectionPath = _videoCollectionPaths[videoId];
    if (collectionPath != null) {
      try {
        await _socialService.incrementView(videoId, collectionPath);
        // Update local view count
        if (mounted) {
          setState(() {
            _videos[index]['views'] = (_videos[index]['views'] as int) + 1;
          });
        }
      } catch (e) {
        print('Error tracking view: $e');
      }
    }

    if (mounted) {
      setState(() {
        _currentVideoIndex = index;
      });
    }
  }

  Future<void> _handleLike(int index) async {
    final videoId = _videos[index]['id'] as String;
    final collectionPath = _videoCollectionPaths[videoId];
    if (collectionPath == null) return;

    final isLiked = _likedVideos[videoId] ?? false;

    try {
      if (isLiked) {
        await _socialService.unlikePost(videoId, collectionPath);
        _likedVideos[videoId] = false;
        setState(() {
          _videos[index]['likes'] = (_videos[index]['likes'] as int) - 1;
        });
      } else {
        await _socialService.likePost(videoId, collectionPath);
        _likedVideos[videoId] = true;
        setState(() {
          _videos[index]['likes'] = (_videos[index]['likes'] as int) + 1;
        });
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

  Future<void> _handleFollow(int index) async {
    final artistId = _videos[index]['artistId'] as String;
    final isFollowing = _followingArtists[artistId] ?? false;

    try {
      if (isFollowing) {
        await _socialService.unfollowArtist(artistId);
        _followingArtists[artistId] = false;
      } else {
        await _socialService.followArtist(artistId);
        _followingArtists[artistId] = true;
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

  Future<void> _showCommentScreen(int index) async {
    final videoId = _videos[index]['id'] as String;
    final collectionPath = _videoCollectionPaths[videoId];
    if (collectionPath == null) return;

    final videoTitle = _videos[index]['title'] as String? ?? 'Video';

    // Navigate to comment screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CommentScreen(
              postId: videoId,
              collectionPath: collectionPath,
              postTitle: videoTitle,
            ),
      ),
    );

    // Refresh comment count when returning from comment screen
    if (result == true && mounted) {
      try {
        // Reload video data to get updated comment count
        final parts = collectionPath.split('/');
        DocumentReference videoRef;

        if (parts.length == 1) {
          videoRef = FirebaseFirestore.instance
              .collection(parts[0])
              .doc(videoId);
        } else if (parts.length == 3) {
          videoRef = FirebaseFirestore.instance
              .collection(parts[0])
              .doc(parts[1])
              .collection(parts[2])
              .doc(videoId);
        } else {
          return;
        }

        final videoDoc = await videoRef.get();
        if (videoDoc.exists && mounted) {
          final data = videoDoc.data() as Map<String, dynamic>;
          setState(() {
            _videos[index]['comments'] = data['comments'] ?? 0;
          });
        }
      } catch (e) {
        print('Error refreshing comment count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          widget.showBackButton
              ? AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                elevation: 0,
              )
              : null,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                ),
              )
              : _videos.isEmpty
              ? const Center(
                child: Text(
                  'No videos available',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _videos.length,
                onPageChanged: (index) {
                  _initializeVideo(index);
                },
                itemBuilder: (context, index) {
                  return _buildVideoPage(index);
                },
              ),
    );
  }

  Widget _buildVideoPage(int index) {
    // Check if this is the current video and it's initialized
    final isCurrentVideo = index == _currentVideoIndex;
    final isInitialized =
        _videoController != null && _videoController!.value.isInitialized;

    if (isCurrentVideo && isInitialized) {
      return Stack(
        children: [
          // Full screen video
          GestureDetector(
            onTap: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          ),
          // Right side overlay - Profile pic and engagement icons
          if (_videos.isNotEmpty)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: () {
                      final artistId = _videos[index]['artistId'] as String?;
                      if (artistId != null && artistId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ArtistProfileScreen(artistId: artistId),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child:
                          _videos[index]['profileImageUrl'] != null
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      _videos[index]['profileImageUrl']
                                          as String,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  placeholder:
                                      (context, url) => Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF00B4FF),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
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
                                          size: 35,
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
                                  size: 35,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Follow Button
                  GestureDetector(
                    onTap: () => _handleFollow(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (_followingArtists[_videos[index]['artistId']
                                        as String] ??
                                    false)
                                ? Colors.grey[700]
                                : const Color(0xFF00B4FF),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        (_followingArtists[_videos[index]['artistId']
                                    as String] ??
                                false)
                            ? Icons.check
                            : Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Engagement Icons
                  GestureDetector(
                    onTap: () => _handleLike(index),
                    child: _buildTikTokEngagementItem(
                      icon: Icons.favorite,
                      count: _formatCount(_videos[index]['likes'] as int? ?? 0),
                      color:
                          (_likedVideos[_videos[index]['id'] as String] ??
                                  false)
                              ? Colors.red
                              : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showCommentScreen(index),
                    child: _buildTikTokEngagementItem(
                      icon: Icons.comment,
                      count: _formatCount(
                        _videos[index]['comments'] as int? ?? 0,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTikTokEngagementItem(
                    icon: Icons.visibility,
                    count: _formatCount(_videos[index]['views'] as int? ?? 0),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          // Bottom overlay - Artist name
          if (_videos.isNotEmpty)
            Positioned(
              left: 16,
              bottom: 80,
              right: 100, // Leave space for right side icons
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _videos[index]['artistName'] as String? ?? 'Unknown Artist',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Video counter at top right (only when no back button)
          if (!widget.showBackButton && _videos.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1}/${_videos.length}',
                  style: const TextStyle(
                    color: Color(0xFF00B4FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Show loading for videos that aren't initialized yet
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
        ),
      );
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Widget _buildTikTokEngagementItem({
    required IconData icon,
    required String count,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 6),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }
}
