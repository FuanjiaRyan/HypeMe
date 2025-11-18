import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'all_artist_post.dart';
import 'choose_screen.dart';
import 'artist_edit_profile_screen.dart';
import 'ai_screen.dart';

class BottomNavbarScreen extends StatefulWidget {
  const BottomNavbarScreen({super.key});

  @override
  State<BottomNavbarScreen> createState() => _BottomNavbarScreenState();
}

class _BottomNavbarScreenState extends State<BottomNavbarScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    const AllArtistPostScreen(showBackButton: false),
    const UploadScreen(),
    const AnalyticsScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[900],
          selectedItemColor: const Color(0xFF00B4FF),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload_outlined),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  final VoidCallback? onUploadTap;

  const HomeScreen({super.key, this.onUploadTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalLikes = 0;
  int _totalComments = 0;
  int _totalFollowers = 0;
  int _totalViews = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      int totalLikes = 0;
      int totalComments = 0;
      int totalViews = 0;
      int totalFollowers = 0;

      // Fetch all videos and sum up likes, comments, and views
      final videosSnapshot =
          await FirebaseFirestore.instance.collection('videos').get();

      for (var videoDoc in videosSnapshot.docs) {
        final vidsSnapshot = await videoDoc.reference.collection('vids').get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          totalLikes += (data['likes'] as int?) ?? 0;
          totalComments += (data['comments'] as int?) ?? 0;
          totalViews += (data['views'] as int?) ?? 0;
        }
      }

      // Fetch all artists and sum up followers
      final artistsSnapshot =
          await FirebaseFirestore.instance.collection('artist').get();

      for (var artistDoc in artistsSnapshot.docs) {
        final data = artistDoc.data();
        totalFollowers += (data['followers'] as int?) ?? 0;
      }

      if (mounted) {
        setState(() {
          _totalLikes = totalLikes;
          _totalComments = totalComments;
          _totalViews = totalViews;
          _totalFollowers = totalFollowers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showAllArtistsPosts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllArtistPostScreen(showBackButton: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with HypeLink title
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF00B4FF),
                        Color(0xFF7B2CBF),
                        Color(0xFFE91E63),
                        Color(0xFFFF6B35),
                      ],
                      stops: [0.0, 0.33, 0.66, 1.0],
                    ).createShader(bounds),
                child: const Text(
                  'HypeLink',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Total Earnings Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF00B4FF), const Color(0xFF7B2CBF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Earnings',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$1,250.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Month',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$450.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last Month',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$800.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Total Views Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Views',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoading ? '...' : _formatCount(_totalViews),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Color(0xFF00B4FF),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Performance Snapshot
              const Text(
                'Performance Snapshot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildPerformanceRow(
                      'Likes',
                      _isLoading ? '...' : _formatCount(_totalLikes),
                      Icons.favorite,
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceRow(
                      'Comments',
                      _isLoading ? '...' : _formatCount(_totalComments),
                      Icons.comment,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceRow(
                      'Followers',
                      _isLoading ? '...' : _formatCount(_totalFollowers),
                      Icons.people,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Upload New Content Button and View Posts Icon
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: widget.onUploadTap,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text(
                          'Upload New Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[700]!, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Navigate to all artists posts feed
                        _showAllArtistsPosts(context);
                      },
                      icon: const Icon(
                        Icons.explore,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'View All Artists Posts',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Upload Screen
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isUploading = false;
  List<Map<String, dynamic>> _recentPosts = [];
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadRecentPosts();
  }

  Future<void> _loadRecentPosts() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
      return;
    }

    try {
      List<Map<String, dynamic>> allPosts = [];

      // Fetch videos from 'videos/{artistId}/vids' subcollection
      final videosDoc =
          await FirebaseFirestore.instance
              .collection('videos')
              .doc(user.uid)
              .get();

      if (videosDoc.exists) {
        final vidsSnapshot = await videosDoc.reference.collection('vids').get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          allPosts.add({
            'id': vidDoc.id,
            'type': 'video',
            'videoUrl': data['videoUrl'] ?? data['url'] ?? '',
            'title': data['title'] ?? 'Untitled',
            'createdAt': data['createdAt'],
            'likes': data['likes'] ?? 0,
            'views': data['views'] ?? 0,
            'comments': data['comments'] ?? 0,
          });
        }
      }

      // Fetch posts from 'posts' collection
      final postsSnapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('artistId', isEqualTo: user.uid)
              .get();

      for (var postDoc in postsSnapshot.docs) {
        final data = postDoc.data();
        allPosts.add({
          'id': postDoc.id,
          'type': data['type'] ?? 'post',
          'videoUrl': data['url'] ?? data['videoUrl'] ?? '',
          'title': data['title'] ?? 'Untitled',
          'createdAt': data['createdAt'],
          'likes': data['likes'] ?? 0,
          'views': data['views'] ?? 0,
          'comments': data['comments'] ?? 0,
        });
      }

      // Sort by createdAt timestamp (most recent first)
      allPosts.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // Descending order (newest first)
      });

      if (mounted) {
        setState(() {
          _recentPosts = allPosts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      print('Error loading recent posts: $e');
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';

    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
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

  Future<void> _uploadVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        if (await file.exists()) {
          await _uploadFileToFirebase(file, 'video', 'videos');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File not found. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFileToFirebase(
    File file,
    String type,
    String folder,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get artist data
      final artistDoc =
          await FirebaseFirestore.instance
              .collection('artist')
              .doc(user.uid)
              .get();

      if (!artistDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artist profile not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final artistData = artistDoc.data()!;
      final artistName = artistData['artistName'] ?? 'Unknown Artist';
      final profileImageUrl = artistData['profileImageUrl'] as String?;

      // Upload file to Firebase Storage
      // Videos are saved to 'videos' folder, audios to 'audios' folder
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '${type}_$timestamp.$extension';
      // Create reference in the specified folder (videos or audios)
      final fileRef = storageRef.child('$folder/$fileName');

      await fileRef.putFile(file);
      final downloadUrl = await fileRef.getDownloadURL();

      // For videos, save to 'videos' collection with 'vids' subcollection
      if (type == 'video') {
        // Get or create the main video document for this artist
        final videoDocRef = FirebaseFirestore.instance
            .collection('videos')
            .doc(user.uid);

        // Check if document exists, if not create it
        final videoDoc = await videoDocRef.get();
        if (!videoDoc.exists) {
          await videoDocRef.set({
            'artistId': user.uid,
            'artistName': artistName,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Add video to 'vids' subcollection
        final vidData = {
          'videoUrl': downloadUrl,
          'title': 'My Video',
          'artistId': user.uid,
          'artistName': artistName,
          'profileImageUrl': profileImageUrl,
          'likes': 0,
          'views': 0,
          'comments': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await videoDocRef.collection('vids').add(vidData);
      } else {
        // For other types, save to 'posts' collection
        final postData = {
          'artistId': user.uid,
          'artistName': artistName,
          'profileImageUrl': profileImageUrl,
          'title': 'My $type',
          'type': type,
          'url': downloadUrl,
          'likes': 0,
          'views': 0,
          'comments': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('posts').add(postData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Reload recent posts and navigate to all artist posts screen
        _loadRecentPosts();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => const AllArtistPostScreen(showBackButton: false),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading $type: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Upload options
              _buildUploadOption(
                icon: Icons.video_library_outlined,
                title: 'Upload Video',
                subtitle:
                    _isUploading ? 'Uploading...' : 'Share your video content',
                onTap: _isUploading ? null : () => _uploadVideo(),
              ),
              const SizedBox(height: 12),
              _buildUploadOption(
                icon: Icons.auto_awesome,
                title: 'AI Beat Creator',
                subtitle: 'Create beats with AI and sing along',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Recent Uploads',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingPosts
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00B4FF),
                        ),
                      ),
                    ),
                  )
                  : _recentPosts.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No uploads yet',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        _recentPosts.length > 10 ? 10 : _recentPosts.length,
                    itemBuilder: (context, index) {
                      final post = _recentPosts[index];
                      final title = post['title'] as String? ?? 'Untitled';
                      final createdAt = post['createdAt'] as Timestamp?;
                      final videoUrl = post['videoUrl'] as String? ?? '';
                      final type = post['type'] as String? ?? 'post';
                      final views = post['views'] as int? ?? 0;
                      final likes = post['likes'] as int? ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[800],
                                child:
                                    videoUrl.isNotEmpty
                                        ? _VideoThumbnailWidget(
                                          videoUrl: videoUrl,
                                        )
                                        : Icon(
                                          type == 'video'
                                              ? Icons.play_circle_outline
                                              : Icons.music_note,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _getTimeAgo(createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.visibility,
                                        size: 12,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatCount(views),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.favorite,
                                        size: 12,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatCount(likes),
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.more_vert, color: Colors.grey[400]),
                          ],
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF00B4FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF00B4FF), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// Analytics Screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _totalViews = 0;
  int _totalLikes = 0;
  int _followers = 0;
  int _following = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _topVideos = [];
  bool _isLoadingVideos = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
    _loadTopVideos();
  }

  Future<void> _loadAnalytics() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Get artist document for followers and following
      final artistDoc =
          await FirebaseFirestore.instance
              .collection('artist')
              .doc(user.uid)
              .get();

      if (artistDoc.exists) {
        final data = artistDoc.data()!;
        _followers = (data['followers'] as int?) ?? 0;
        _following = (data['following'] as int?) ?? 0;
      }

      // Sum up views and likes from all videos
      int totalViews = 0;
      int totalLikes = 0;

      // Get videos from 'videos/{artistId}/vids' subcollection
      final videosDoc =
          await FirebaseFirestore.instance
              .collection('videos')
              .doc(user.uid)
              .get();

      if (videosDoc.exists) {
        final vidsSnapshot = await videosDoc.reference.collection('vids').get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          totalViews += (data['views'] as int?) ?? 0;
          totalLikes += (data['likes'] as int?) ?? 0;
        }
      }

      // Get posts from 'posts' collection
      final postsSnapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('artistId', isEqualTo: user.uid)
              .get();

      for (var postDoc in postsSnapshot.docs) {
        final data = postDoc.data();
        totalViews += (data['views'] as int?) ?? 0;
        totalLikes += (data['likes'] as int?) ?? 0;
      }

      if (mounted) {
        setState(() {
          _totalViews = totalViews;
          _totalLikes = totalLikes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTopVideos() async {
    try {
      List<Map<String, dynamic>> allVideos = [];

      // Get all videos from all artists in 'videos' collection
      final videosSnapshot =
          await FirebaseFirestore.instance.collection('videos').get();

      // Iterate through each artist's video document
      for (var videoDoc in videosSnapshot.docs) {
        // Get all videos from this artist's 'vids' subcollection
        final vidsSnapshot = await videoDoc.reference.collection('vids').get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          final likes = (data['likes'] as int?) ?? 0;
          final comments = (data['comments'] as int?) ?? 0;
          final views = (data['views'] as int?) ?? 0;

          // Calculate interactivity score (likes + comments + views)
          final interactivityScore = likes + comments + views;

          allVideos.add({
            'id': vidDoc.id,
            'videoUrl': data['videoUrl'] ?? data['url'] ?? '',
            'title': data['title'] ?? 'Untitled',
            'artistName': data['artistName'] ?? 'Unknown Artist',
            'artistId': videoDoc.id,
            'likes': likes,
            'views': views,
            'comments': comments,
            'interactivityScore': interactivityScore,
            'createdAt': data['createdAt'],
          });
        }
      }

      // Get all posts from 'posts' collection (all artists)
      final postsSnapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      for (var postDoc in postsSnapshot.docs) {
        final data = postDoc.data();
        final likes = (data['likes'] as int?) ?? 0;
        final comments = (data['comments'] as int?) ?? 0;
        final views = (data['views'] as int?) ?? 0;

        // Calculate interactivity score
        final interactivityScore = likes + comments + views;

        allVideos.add({
          'id': postDoc.id,
          'videoUrl': data['url'] ?? data['videoUrl'] ?? '',
          'title': data['title'] ?? 'Untitled',
          'artistName': data['artistName'] ?? 'Unknown Artist',
          'artistId': data['artistId'] ?? '',
          'likes': likes,
          'views': views,
          'comments': comments,
          'interactivityScore': interactivityScore,
          'createdAt': data['createdAt'],
        });
      }

      // Sort by interactivity score (descending - most interactive first)
      allVideos.sort((a, b) {
        final scoreA = a['interactivityScore'] as int;
        final scoreB = b['interactivityScore'] as int;
        return scoreB.compareTo(scoreA);
      });

      if (mounted) {
        setState(() {
          _topVideos = allVideos;
          _isLoadingVideos = false;
        });
      }
    } catch (e) {
      print('Error loading top videos: $e');
      if (mounted) {
        setState(() {
          _isLoadingVideos = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Views',
                      value: _isLoading ? '...' : _formatCount(_totalViews),
                      icon: Icons.visibility_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Likes',
                      value: _isLoading ? '...' : _formatCount(_totalLikes),
                      icon: Icons.favorite_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Followers',
                      value: _isLoading ? '...' : _formatCount(_followers),
                      icon: Icons.people_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Following',
                      value: _isLoading ? '...' : _formatCount(_following),
                      icon: Icons.person_add_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Top Performing Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingVideos
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00B4FF),
                        ),
                      ),
                    ),
                  )
                  : _topVideos.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No content yet',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _topVideos.length,
                    itemBuilder: (context, index) {
                      final video = _topVideos[index];
                      final videoUrl = video['videoUrl'] as String? ?? '';
                      final title = video['title'] as String? ?? 'Untitled';
                      final artistName =
                          video['artistName'] as String? ?? 'Unknown Artist';
                      final views = video['views'] as int? ?? 0;
                      final likes = video['likes'] as int? ?? 0;
                      final comments = video['comments'] as int? ?? 0;
                      final interactivityScore =
                          video['interactivityScore'] as int? ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Video Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[800],
                                child:
                                    videoUrl.isNotEmpty
                                        ? _VideoThumbnailWidget(
                                          videoUrl: videoUrl,
                                        )
                                        : const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'by $artistName',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 14,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatCount(views)} views',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.favorite,
                                        size: 14,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatCount(likes)}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.comment,
                                        size: 14,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatCount(comments)}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCount(interactivityScore),
                                  style: const TextStyle(
                                    color: Color(0xFF00B4FF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'score',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00B4FF), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

// Wallet Screen
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Balance card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF00B4FF), const Color(0xFF7B2CBF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$1,250.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$1,250.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$0.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Withdraw'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isPositive = index % 3 == 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                isPositive
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPositive
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPositive ? 'Payment Received' : 'Withdrawal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${index + 1} days ago',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isPositive ? '+' : '-'}\$${(index + 1) * 25}.00',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;
  bool _isLoadingStats = true;
  List<Map<String, dynamic>> _artistVideos = [];
  bool _isLoadingVideos = true;

  @override
  void initState() {
    super.initState();
    _loadProfileStats();
    _loadArtistVideos();
  }

  Future<void> _loadProfileStats() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Get artist document
      final artistDoc =
          await FirebaseFirestore.instance
              .collection('artist')
              .doc(user.uid)
              .get();

      if (artistDoc.exists) {
        final data = artistDoc.data()!;
        _followersCount = (data['followers'] as int?) ?? 0;
        _followingCount = (data['following'] as int?) ?? 0;
      }

      // Count posts from 'posts' collection
      final postsSnapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('artistId', isEqualTo: user.uid)
              .get();

      int postsCount = postsSnapshot.docs.length;

      // Count videos from 'videos/{artistId}/vids' subcollection
      final videosDoc =
          await FirebaseFirestore.instance
              .collection('videos')
              .doc(user.uid)
              .get();

      if (videosDoc.exists) {
        final vidsSnapshot = await videosDoc.reference.collection('vids').get();
        postsCount += vidsSnapshot.docs.length;
      }

      if (mounted) {
        setState(() {
          _postsCount = postsCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading profile stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadArtistVideos() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Fetch videos from 'videos/{artistId}/vids' subcollection
      final videosDoc =
          await FirebaseFirestore.instance
              .collection('videos')
              .doc(user.uid)
              .get();

      List<Map<String, dynamic>> videos = [];

      if (videosDoc.exists) {
        final vidsSnapshot =
            await videosDoc.reference
                .collection('vids')
                .orderBy('createdAt', descending: true)
                .get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          videos.add({
            'id': vidDoc.id,
            'videoUrl': data['videoUrl'] ?? data['url'] ?? '',
            'title': data['title'] ?? 'Untitled',
            'likes': data['likes'] ?? 0,
            'views': data['views'] ?? 0,
            'comments': data['comments'] ?? 0,
            'createdAt': data['createdAt'],
          });
        }
      }

      if (mounted) {
        setState(() {
          _artistVideos = videos;
          _isLoadingVideos = false;
        });
      }
    } catch (e) {
      print('Error loading artist videos: $e');
      if (mounted) {
        setState(() {
          _isLoadingVideos = false;
        });
      }
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

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFF00B4FF)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to ChooseScreen and remove all previous routes
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChooseScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
        child: const Center(
          child: Text('Please sign in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
      child: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('artist')
                  .doc(user.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Profile not found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final artistData = snapshot.data!.data() as Map<String, dynamic>;
            final profileImageUrl = artistData['profileImageUrl'] as String?;
            final artistName =
                artistData['artistName'] as String? ?? 'Artist Name';
            final email = artistData['email'] as String? ?? '';
            final bio = artistData['bio'] as String? ?? '';

            // Update stats when artist data changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final followers = (artistData['followers'] as int?) ?? 0;
                final following = (artistData['following'] as int?) ?? 0;
                if (_followersCount != followers ||
                    _followingCount != following) {
                  setState(() {
                    _followersCount = followers;
                    _followingCount = following;
                  });
                }
              }
            });

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF0A0E27),
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: Colors.grey[900],
                      onSelected: (value) {
                        if (value == 'edit_profile') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ArtistEditProfileScreen(),
                            ),
                          );
                        } else if (value == 'settings') {
                          // Settings functionality (can be implemented later)
                        } else if (value == 'logout') {
                          _handleLogout(context);
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit_profile',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'settings',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Settings',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0A0E27),
                            const Color(0xFF1A0F2E),
                          ],
                        ),
                      ),
                    ),
                    centerTitle: true,
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                            border: Border.all(
                              color: const Color(0xFF00B4FF),
                              width: 3,
                            ),
                          ),
                          child:
                              profileImageUrl != null &&
                                      profileImageUrl.isNotEmpty
                                  ? GestureDetector(
                                    onTap: () {
                                      _showFullScreenImage(
                                        context,
                                        profileImageUrl,
                                      );
                                    },
                                    child: ClipOval(
                                      child: Image.network(
                                        profileImageUrl,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[800],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                strokeWidth: 3,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF00B4FF)),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          // If network image fails, try CachedNetworkImage as fallback
                                          return CachedNetworkImage(
                                            imageUrl: profileImageUrl,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            placeholder:
                                                (context, url) => Container(
                                                  color: Colors.grey[800],
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 30,
                                                      height: 30,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 3,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              Color(0xFF00B4FF),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 50,
                                                    ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 50,
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
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              'Followers',
                              _isLoadingStats
                                  ? '...'
                                  : _formatCount(_followersCount),
                            ),
                            _buildStatColumn(
                              'Following',
                              _isLoadingStats
                                  ? '...'
                                  : _formatCount(_followingCount),
                            ),
                            _buildStatColumn(
                              'Posts',
                              _isLoadingStats
                                  ? '...'
                                  : _formatCount(_postsCount),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Bio Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bio.isNotEmpty ? bio : 'No bio available',
                                style: TextStyle(
                                  color:
                                      bio.isNotEmpty
                                          ? Colors.grey[300]
                                          : Colors.grey[500],
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Artist Posts Section
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Posts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFF00B4FF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Posts Grid
                        _isLoadingVideos
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00B4FF),
                                  ),
                                ),
                              ),
                            )
                            : _artistVideos.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No videos yet',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                              itemCount:
                                  _artistVideos.length > 9
                                      ? 9
                                      : _artistVideos.length,
                              itemBuilder: (context, index) {
                                final video = _artistVideos[index];
                                final videoUrl =
                                    video['videoUrl'] as String? ?? '';
                                final likes = video['likes'] as int? ?? 0;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const AllArtistPostScreen(
                                                  showBackButton: true,
                                                ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Video Thumbnail
                                          if (videoUrl.isNotEmpty)
                                            _VideoThumbnailWidget(
                                              videoUrl: videoUrl,
                                            )
                                          else
                                            Container(
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.play_circle_outline,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                          // Play Icon Overlay
                                          const Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                          // Overlay with likes info
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            right: 4,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.6,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatCount(likes),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImagePage(imageUrl: imageUrl),
        fullscreenDialog: true,
      ),
    );
  }
}

// Video Thumbnail Widget
class _VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnailWidget({required this.videoUrl});

  @override
  State<_VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller!.initialize();
      // Seek to a frame (e.g., 1 second) to get a good thumbnail
      await _controller!.seekTo(const Duration(seconds: 1));
      // Pause the video
      await _controller!.pause();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.videocam_off, color: Colors.white, size: 40),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

// All Artists Posts Screen
class AllArtistsPostsScreen extends StatelessWidget {
  const AllArtistsPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          'All Artists Posts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0E27)),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: 20,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artist header
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Artist ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${index + 1} hours ago',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Post content placeholder
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Post description
                    Text(
                      'Check out my latest work! This is an amazing piece of art that I\'ve been working on.',
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    // Engagement buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEngagementButton(
                          icon: Icons.favorite_outline,
                          label: '${(index + 1) * 25}',
                          onTap: () {},
                        ),
                        _buildEngagementButton(
                          icon: Icons.comment_outlined,
                          label: '${(index + 1) * 5}',
                          onTap: () {},
                        ),
                        _buildEngagementButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

// Full Screen Image Viewer
class _FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00B4FF),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
