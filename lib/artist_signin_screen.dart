import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ArtistSignInScreen extends StatefulWidget {
  const ArtistSignInScreen({super.key});

  @override
  State<ArtistSignInScreen> createState() => _ArtistSignInScreenState();
}

class _ArtistSignInScreenState extends State<ArtistSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _artistNameController = TextEditingController();
  final _shortBioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  
  File? _profilePicture;
  final int _maxBioLength = 150;
  
  // Additional social media fields
  final List<Map<String, dynamic>> _additionalSocials = [];

  @override
  void dispose() {
    _artistNameController.dispose();
    _shortBioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    for (var social in _additionalSocials) {
      social['controller']?.dispose();
    }
    super.dispose();
  }

  double _calculateProgress() {
    int completedFields = 0;
    int totalFields = 4; // Profile picture, Artist name, Short bio, Social links
    
    // Profile picture (optional but counts if added)
    if (_profilePicture != null) completedFields++;
    
    // Artist name
    if (_artistNameController.text.trim().isNotEmpty) completedFields++;
    
    // Short bio
    if (_shortBioController.text.trim().isNotEmpty) completedFields++;
    
    // Social links (at least one)
    if (_instagramController.text.trim().isNotEmpty || 
        _twitterController.text.trim().isNotEmpty ||
        _additionalSocials.any((social) => social['controller']?.text.trim().isNotEmpty ?? false)) {
      completedFields++;
    }
    
    return completedFields / totalFields;
  }

  Future<void> _pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    
    // Show dialog to choose between camera and gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select Image Source',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );

        if (pickedFile != null) {
          setState(() {
            _profilePicture = File(pickedFile.path);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _addMoreSocial() {
    setState(() {
      _additionalSocials.add({
        'platform': 'Social Media',
        'controller': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set Up Your Artist Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0E27),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4FF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Introductory text
                  const Text(
                    'Let your fans get to know you. You can change this information anytime.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickProfilePicture,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              color: Colors.grey[900],
                            ),
                            child: _profilePicture != null
                                ? ClipOval(
                                    child: Image.file(
                                      _profilePicture!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Profile Picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _pickProfilePicture,
                          child: const Text(
                            'Tap to upload',
                            style: TextStyle(
                              color: Color(0xFF00B4FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Artist Name field
                  const Text(
                    'Artist Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _artistNameController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}), // Update progress
                    decoration: InputDecoration(
                      hintText: 'Enter your artist name or handle',
                      hintStyle: TextStyle(color: Colors.grey[400]),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your artist name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Short Bio field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Short Bio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_shortBioController.text.length}/$_maxBioLength',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _shortBioController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: _maxBioLength,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}), // Update progress
                    decoration: InputDecoration(
                      hintText: 'Tell us about your art...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
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
                      counterText: '', // Hide default counter
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Link Your Socials section
                  const Text(
                    'Link Your Socials',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Instagram field
                  TextFormField(
                    controller: _instagramController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}), // Update progress
                    decoration: InputDecoration(
                      hintText: 'e.g., yourusername',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
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
                  ),
                  const SizedBox(height: 12),
                  // Twitter field
                  TextFormField(
                    controller: _twitterController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}), // Update progress
                    decoration: InputDecoration(
                      hintText: 'e.g., yourusername',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(
                        Icons.alternate_email,
                        color: Colors.white,
                        size: 20,
                      ),
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
                  ),
                  // Additional social fields
                  ..._additionalSocials.map((social) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        controller: social['controller'],
                        style: const TextStyle(color: Colors.white),
                        onChanged: (_) => setState(() {}), // Update progress
                        decoration: InputDecoration(
                          hintText: 'e.g., yourusername',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.link,
                            color: Colors.white,
                            size: 20,
                          ),
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
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Add more link
                  GestureDetector(
                    onTap: _addMoreSocial,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: Color(0xFF00B4FF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add more',
                          style: TextStyle(
                            color: Color(0xFF00B4FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Complete Profile button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile completed successfully!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Complete Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Skip for Now link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Handle skip action
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Skip for Now',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
