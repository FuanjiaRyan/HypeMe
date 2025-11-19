import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_screen.dart';

class MarketPlaceScreen extends StatefulWidget {
  const MarketPlaceScreen({super.key});

  @override
  State<MarketPlaceScreen> createState() => _MarketPlaceScreenState();
}

class _MarketPlaceScreenState extends State<MarketPlaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMediaType = 'All';
  String _sortBy = 'Newest';
  List<Map<String, dynamic>> _nfts = [];
  List<Map<String, dynamic>> _filteredNfts = [];
  bool _isLoading = true;
  bool _isArtist = false;

  @override
  void initState() {
    super.initState();
    _checkIfArtist();
    _loadNFTs();
    _searchController.addListener(_filterNFTs);
  }

  Future<void> _checkIfArtist() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isArtist = false;
      });
      return;
    }

    try {
      final artistDoc = await FirebaseFirestore.instance
          .collection('artist')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _isArtist = artistDoc.exists;
        });
      }
    } catch (e) {
      print('Error checking if user is artist: $e');
      if (mounted) {
        setState(() {
          _isArtist = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNFTs() async {
    try {
      // Fetch NFTs from Firestore
      // Assuming NFTs are stored in a 'marketplace' or 'nfts' collection
      final nftsSnapshot = await FirebaseFirestore.instance
          .collection('marketplace')
          .get();

      List<Map<String, dynamic>> nfts = [];

      for (var doc in nftsSnapshot.docs) {
        final data = doc.data();
        nfts.add({
          'id': doc.id,
          'title': data['title'] ?? 'Untitled',
          'type': data['type'] ?? 'Audio',
          'artist': data['artist'] ?? data['artistName'] ?? 'Unknown Artist',
          'price': data['price'] ?? '0.25 ETH',
          'thumbnailUrl': data['thumbnailUrl'] ?? data['imageUrl'] ?? '',
          'videoUrl': data['videoUrl'] ?? data['url'] ?? '',
          'createdAt': data['createdAt'],
        });
      }

      // Sort by newest first
      nfts.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          _nfts = nfts;
          _filteredNfts = List.from(nfts);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading NFTs: $e');
      // If collection doesn't exist, use sample data
      _loadSampleNFTs();
    }
  }

  void _loadSampleNFTs() {
    // Sample data with prices, artist names, and types
    final sampleNFTs = [
      {
        'id': '1',
        'title': 'Song Cover Art 1',
        'type': 'Audio',
        'artist': 'Starlight Echoes',
        'price': '0.15 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '2',
        'title': 'Neon Streets',
        'type': 'Video',
        'artist': 'Starlight Echoes',
        'price': '0.30 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '3',
        'title': 'Video Thumbnail 2',
        'type': 'Video',
        'artist': 'Cosmic Beats',
        'price': '0.25 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '4',
        'title': 'Cosmic Reverie 2',
        'type': 'Video',
        'artist': 'Starlight Echoes',
        'price': '0.25 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '5',
        'title': 'Neon Streets',
        'type': 'Video',
        'artist': 'Digital Dreams',
        'price': '0.20 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '6',
        'title': 'Forest Whispers 3',
        'type': 'Audio',
        'artist': 'Nature Sounds',
        'price': '0.18 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '7',
        'title': 'Electric Pulse',
        'type': 'Audio',
        'artist': 'Starlight Echoes',
        'price': '0.22 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '8',
        'title': 'Midnight Vibes',
        'type': 'Video',
        'artist': 'Cosmic Beats',
        'price': '0.28 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
      {
        'id': '9',
        'title': 'Sunset Dreams',
        'type': 'Audio',
        'artist': 'Digital Dreams',
        'price': '0.19 ETH',
        'thumbnailUrl': '',
        'videoUrl': '',
      },
    ];

    if (mounted) {
      setState(() {
        _nfts = sampleNFTs;
        _filteredNfts = List.from(sampleNFTs);
        _isLoading = false;
      });
    }
  }

  void _filterNFTs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNfts = _nfts.where((nft) {
        final matchesSearch = query.isEmpty ||
            nft['title'].toString().toLowerCase().contains(query) ||
            nft['artist'].toString().toLowerCase().contains(query);
        final matchesType = _selectedMediaType == 'All' ||
            nft['type'].toString() == _selectedMediaType;
        return matchesSearch && matchesType;
      }).toList();

      // Apply sorting
      if (_sortBy == 'Newest') {
        _filteredNfts.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
      } else if (_sortBy == 'Oldest') {
        _filteredNfts.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return -1;
          if (bTime == null) return 1;
          return aTime.compareTo(bTime);
        });
      }
    });
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
        elevation: 0,
        actions: _isArtist
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00B4FF)),
                  onPressed: _showListNftDialog,
                  tooltip: 'List New NFT',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User ID and Connect Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // User ID
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ID: 0xABC...123',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Connect Button
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Main Heading
                const Text(
                  'Earn from Artist PNFT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Sub Heading
                const Text(
                  'Earn money by buying exclusive PNFT from your favourite Artist',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search PNFTs...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
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
                const SizedBox(height: 16),
                // Filters and Sort
                Row(
                  children: [
                    // Media Type Filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedMediaType,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.grey[800],
                          style: const TextStyle(color: Colors.white),
                          items: ['All', 'Audio', 'Video']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMediaType = value!;
                              _filterNFTs();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort By
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.grey[800],
                          style: const TextStyle(color: Colors.white),
                          items: ['Newest', 'Oldest']
                              .map((sort) => DropdownMenuItem(
                                    value: sort,
                                    child: Text(sort),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value!;
                              _filterNFTs();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Status: Displaying live data from Firestore.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                // NFT Grid
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00B4FF),
                            ),
                          ),
                        ),
                      )
                        : _filteredNfts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.store_outlined,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No PNFTs Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to list a PNFT!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _showListNftDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('List NFT'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B4FF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.75, // Adjusted for better proportions
                            ),
                            itemCount: _filteredNfts.length,
                            itemBuilder: (context, index) {
                              final nft = _filteredNfts[index];
                              return _buildNftCard(nft);
                            },
                          ),
                const SizedBox(height: 32),
                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        '© 2023 HypaLink. All rights reserved.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Powered by Google Stitch.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNftCard(Map<String, dynamic> nft) {
    final title = nft['title'] as String? ?? 'Untitled';
    final type = nft['type'] as String? ?? 'Audio';
    final artist = nft['artist'] as String? ?? 'Unknown Artist';
    final price = nft['price'] as String? ?? '0.00 ETH';
    final thumbnailUrl = nft['thumbnailUrl'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutScreen(pnft: nft),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NFT Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: thumbnailUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF00B4FF),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => _buildGradientPlaceholder(),
                            )
                          : _buildGradientPlaceholder(),
                      
                      // Type Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type == 'Video' ? Icons.videocam : Icons.music_note,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
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
              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00B4FF),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF00B4FF),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B4FF).withOpacity(0.8),
            const Color(0xFF7B2CBF).withOpacity(0.8),
          ],
        ),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white,
        size: 40,
      ),
    );
  }


  void _showListNftDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    String selectedType = 'Audio';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('List New NFT', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Price (ETH)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedType,
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                isExpanded: true,
                items: ['Audio', 'Video'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  try {
                    final newNft = {
                      'title': titleController.text,
                      'price': '${priceController.text} ETH',
                      'type': selectedType,
                      'artist': 'Current User', // Replace with actual user name
                      'createdAt': FieldValue.serverTimestamp(),
                      'thumbnailUrl': '', // Placeholder
                    };

                    await FirebaseFirestore.instance.collection('marketplace').add(newNft);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      _loadNFTs(); // Reload list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('NFT Listed Successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    print('Error listing NFT: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to list NFT'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B4FF)),
              child: const Text('List', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

