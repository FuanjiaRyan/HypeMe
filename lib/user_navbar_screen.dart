import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'all_artist_post.dart';
import 'user_edit_profile_screen.dart';
import 'choose_screen.dart';
import 'market_place.dart';

class UserNavbarScreen extends StatefulWidget {
  const UserNavbarScreen({super.key});

  @override
  State<UserNavbarScreen> createState() => _UserNavbarScreenState();
}

class _UserNavbarScreenState extends State<UserNavbarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AllArtistPostScreen(showBackButton: false), // Home page - no back button
    const ExploreScreen(),
    const UserWalletScreen(),
    const UserProfileScreen(),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
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

// User Home Screen
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E27),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0A0E27),
              flexibleSpace: FlexibleSpaceBar(
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trending Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllArtistPostScreen(showBackButton: true),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Track ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Artist Name',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'For You',
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
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllArtistPostScreen(showBackButton: true),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Content ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Artist Name',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[400],
                                ),
                              ],
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
        ),
      ),
    );
  }
}

// Explore Screen
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allVideos = [];
  List<Map<String, dynamic>> _filteredVideos = [];
  List<Map<String, dynamic>> _allArtists = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _loadArtists();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      _filterVideos();
    });
  }

  void _filterVideos() {
    if (_searchQuery.isEmpty) {
      _filteredVideos = List.from(_allVideos);
    } else {
      _filteredVideos = _allVideos.where((video) {
        final artistName = (video['artistName'] as String? ?? '').toLowerCase();
        final title = (video['title'] as String? ?? '').toLowerCase();
        return artistName.contains(_searchQuery) || title.contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadArtists() async {
    try {
      final artistsSnapshot = await FirebaseFirestore.instance
          .collection('artist')
          .get();

      _allArtists = artistsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'artistName': data['artistName'] ?? 'Unknown Artist',
          'profileImageUrl': data['profileImageUrl'],
          'email': data['email'],
        };
      }).toList();
    } catch (e) {
      print('Error loading artists: $e');
    }
  }

  Future<void> _loadVideos() async {
    try {
      // Fetch all documents from 'videos' collection
      final videosSnapshot =
          await FirebaseFirestore.instance.collection('videos').get();

      List<Map<String, dynamic>> allVideos = [];

      // For each document in 'videos', get all documents from 'vids' subcollection
      for (var videoDoc in videosSnapshot.docs) {
        final vidsSnapshot = await videoDoc.reference
            .collection('vids')
            .orderBy('createdAt', descending: true)
            .get();

        for (var vidDoc in vidsSnapshot.docs) {
          final data = vidDoc.data();
          final videoId = vidDoc.id;
          final artistId = data['artistId'] ?? videoDoc.id;

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
        }
      }

      if (mounted) {
        setState(() {
          _allVideos = allVideos;
          _filteredVideos = List.from(allVideos);
          _isLoading = false;
        });
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
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E27),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search artists, songs, videos...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            // Videos Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                      ),
                    )
                  : _filteredVideos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                color: Colors.grey[600],
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No videos found'
                                    : 'No videos available',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                ),
                          itemCount: _filteredVideos.length,
                itemBuilder: (context, index) {
                            final video = _filteredVideos[index];
                            final videoUrl = video['videoUrl'] as String? ?? '';
                            final artistName =
                                video['artistName'] as String? ?? 'Unknown Artist';
                            final likes = video['likes'] as int? ?? 0;
                            final profileImageUrl =
                                video['profileImageUrl'] as String?;
                            final videoId = video['id'] as String;

                  return GestureDetector(
                    onTap: () {
                                // Navigate to video player
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                                    builder: (context) =>
                                        const AllArtistPostScreen(showBackButton: true),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                      ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                                      // Background: Artist Profile Picture
                                      if (profileImageUrl != null &&
                                          profileImageUrl.isNotEmpty)
                                        CachedNetworkImage(
                                          imageUrl: profileImageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[900],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF00B4FF),
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.orange[300]!,
                                                  Colors.green[300]!,
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.orange[300]!,
                                                Colors.green[300]!,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      // Overlay: Video Thumbnail/Preview
                                      if (videoUrl.isNotEmpty)
                                        Positioned.fill(
                            child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                ),
                              child: const Icon(
                                                  Icons.play_circle_filled,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                                          ),
                                        ),
                                      // Bottom Overlay: Video Info
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                                Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                                artistName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                  Text(
                                                    _formatCount(likes),
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                                  ),
                                                ],
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
            ),
          ],
        ),
      ),
    );
  }
}

// User Wallet Screen
class UserWalletScreen extends StatelessWidget {
  const UserWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E27),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'My Wallet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
              const SizedBox(height: 24),
              // Available Balance card with purple gradient and green glow
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF7B2CBF), // Purple
                      const Color(0xFF9B59B6), // Lighter purple
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'FCFA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '1,520.50',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Lifetime Earnings and Last Payout cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lifetime Earnings',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'FCFA 8,450.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Payout',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'FCFA 500.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Withdraw Funds button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text(
                    'Withdraw Funds',
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
              const SizedBox(height: 16),
              // MTN Mobile Money withdrawal option
              Container(
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
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'MTN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Withdraw to MTN MoMo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Market Place button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketPlaceScreen(),
                    ),
                  );
                },
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
                          color: const Color(0xFF00B4FF),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Market Place',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Payout History section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payout History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Payout History entries
              _buildPayoutEntry(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: 'Payout',
                date: 'Oct 28, 2023',
                amount: '- FCFA 500.00',
                status: 'Completed',
                statusColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildPayoutEntry(
                icon: Icons.sync,
                iconColor: Colors.yellow,
                title: 'Payout',
                date: 'Oct 15, 2023',
                amount: '- FCFA 250.50',
                status: 'Processing',
                statusColor: Colors.yellow,
              ),
              const SizedBox(height: 12),
              _buildPayoutEntry(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: 'Payout',
                date: 'Sep 30, 2023',
                amount: '- FCFA 1,200.00',
                status: 'Completed',
                statusColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutEntry({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                  date,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// User Profile Screen (Settings)
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E27),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    _buildUserProfileSection(),
                    const SizedBox(height: 32),
                    // General Settings Section
                    const Text(
                      'General Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dark Mode
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.dark_mode,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dark Mode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Switch between light and dark themes.',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                            activeColor: const Color(0xFF00B4FF),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Notifications
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Support & Legal Section
                    const Text(
                      'Support & Legal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showPrivacyPolicyDialog(context),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      icon: Icons.gavel_outlined,
                      title: 'Terms of Service',
                      onTap: () => _showTermsOfServiceDialog(context),
                    ),
                    const SizedBox(height: 32),
                    // Log Out button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Show confirmation dialog
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Color(0xFF00B4FF),
                                      ),
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
                                MaterialPageRoute(
                                  builder: (context) => const ChooseScreen(),
                                ),
                                (route) => false, // Remove all previous routes
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000), // Dark red/maroon
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Version
                    const Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    final User? user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 16),
            Text(
              'No user logged in',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4FF)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_off, color: Colors.grey),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'User profile not found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final profileImageUrl = userData['profileImageUrl'] as String?;
        final fullName = userData['fullName'] as String? ?? 'User';
        final email = userData['email'] as String? ?? '';

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserEditProfileScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? () {
                          _showFullScreenImage(context, profileImageUrl);
                        }
                      : null,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00B4FF),
                        width: 2,
                      ),
                    ),
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 3,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00B4FF),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return CachedNetworkImage(
                                  imageUrl: profileImageUrl,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
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
                                      size: 35,
                                    ),
                                  ),
                                );
                              },
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isNotEmpty ? email : 'No email',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
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

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip_outlined,
                        color: Color(0xFF00B4FF),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Updated: January 2024',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '1. Information We Collect',
                          'We collect information that you provide directly to us, including:\n\n'
                          '• Account information (name, email, profile picture)\n'
                          '• Content you create and share (videos, comments, likes)\n'
                          '• Usage data and analytics\n'
                          '• Device information and identifiers',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '2. How We Use Your Information',
                          'We use the information we collect to:\n\n'
                          '• Provide and improve our services\n'
                          '• Personalize your experience\n'
                          '• Communicate with you about our services\n'
                          '• Ensure platform security and prevent fraud\n'
                          '• Comply with legal obligations',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '3. Information Sharing',
                          'We do not sell your personal information. We may share your information only:\n\n'
                          '• With your consent\n'
                          '• To comply with legal obligations\n'
                          '• To protect our rights and safety\n'
                          '• With service providers who assist us in operating our platform',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '4. Data Security',
                          'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '5. Your Rights',
                          'You have the right to:\n\n'
                          '• Access your personal data\n'
                          '• Correct inaccurate data\n'
                          '• Delete your account and data\n'
                          '• Object to processing of your data\n'
                          '• Data portability',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '6. Contact Us',
                          'If you have questions about this Privacy Policy, please contact us at:\n\n'
                          'Email: privacy@hypelink.com\n'
                          'Address: [Your Company Address]',
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'I Understand',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.gavel_outlined,
                        color: Color(0xFF00B4FF),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Updated: January 2024',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '1. Acceptance of Terms',
                          'By accessing and using HypeLink, you accept and agree to be bound by these Terms of Service. If you do not agree, please do not use our service.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '2. User Accounts',
                          'You are responsible for:\n\n'
                          '• Maintaining the confidentiality of your account\n'
                          '• All activities that occur under your account\n'
                          '• Providing accurate and complete information\n'
                          '• Notifying us of any unauthorized use',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '3. User Content',
                          'You retain ownership of content you post. By posting, you grant us:\n\n'
                          '• A worldwide, non-exclusive license to use, display, and distribute your content\n'
                          '• The right to remove content that violates these terms\n\n'
                          'You agree not to post content that is:\n'
                          '• Illegal, harmful, or offensive\n'
                          '• Infringing on others\' rights\n'
                          '• Spam or misleading',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '4. Prohibited Activities',
                          'You agree not to:\n\n'
                          '• Violate any laws or regulations\n'
                          '• Infringe on intellectual property rights\n'
                          '• Harass, abuse, or harm others\n'
                          '• Interfere with the service\'s operation\n'
                          '• Use automated systems to access the service\n'
                          '• Attempt to gain unauthorized access',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '5. Intellectual Property',
                          'The service and its original content, features, and functionality are owned by HypeLink and are protected by international copyright, trademark, and other intellectual property laws.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '6. Termination',
                          'We may terminate or suspend your account immediately, without prior notice, for conduct that we believe violates these Terms of Service or is harmful to other users, us, or third parties.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '7. Disclaimer of Warranties',
                          'The service is provided "as is" and "as available" without warranties of any kind, either express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, or non-infringement.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '8. Limitation of Liability',
                          'To the fullest extent permitted by law, HypeLink shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '9. Changes to Terms',
                          'We reserve the right to modify these terms at any time. We will notify users of any material changes. Your continued use of the service constitutes acceptance of the modified terms.',
                        ),
                        const SizedBox(height: 20),
                        _buildPolicySection(
                          '10. Contact Information',
                          'If you have questions about these Terms of Service, please contact us at:\n\n'
                          'Email: legal@hypelink.com\n'
                          'Address: [Your Company Address]',
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'I Agree',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00B4FF),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

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
                  value: loadingProgress.expectedTotalBytes != null
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

