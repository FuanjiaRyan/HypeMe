import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_navbar_screen.dart';
import 'artist_login_screen.dart';

class ArtistSignInScreen extends StatefulWidget {
  const ArtistSignInScreen({super.key});

  @override
  State<ArtistSignInScreen> createState() => _ArtistSignInScreenState();
}

class _ArtistSignInScreenState extends State<ArtistSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _artistNameController = TextEditingController();
  final _shortBioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  
  File? _profilePicture;
  final int _maxBioLength = 150;
  bool _obscurePassword = true;
  bool _isUploading = false;
  
  // Additional social media fields
  final List<Map<String, dynamic>> _additionalSocials = [];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    int totalFields = 6; // Email, Password, Profile picture, Artist name, Short bio, Social links
    
    // Email
    if (_emailController.text.trim().isNotEmpty) completedFields++;
    
    // Password
    if (_passwordController.text.trim().isNotEmpty) completedFields++;
    
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

  Future<String?> _uploadProfilePicture() async {
    if (_profilePicture == null) {
      return null; // No image to upload
    }

    try {
      // Get a reference to the storage location
      final storageRef = FirebaseStorage.instance.ref();
      
      // Get file extension from the path
      final String fileExtension = _profilePicture!.path.split('.').last;
      
      // Create a unique filename using timestamp
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      // Reference to the file location in Firebase Storage
      final profilePicRef = storageRef.child('artistProfiles/$fileName');

      // Upload the file
      await profilePicRef.putFile(_profilePicture!);

      // Get the download URL
      final String downloadUrl = await profilePicRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading profile picture: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Future<bool> _saveArtistProfile(String? imageUrl) async {
    try {
      // Create Firebase Auth account
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Prepare data to save to Firestore
      final Map<String, dynamic> artistData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(), // Note: Storing password in Firestore is not recommended for production
        'artistName': _artistNameController.text.trim(),
        'bio': _shortBioController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add image URL if available
      if (imageUrl != null) {
        artistData['profileImageUrl'] = imageUrl;
      }

      // Add social media links if available
      if (_instagramController.text.trim().isNotEmpty) {
        artistData['instagram'] = _instagramController.text.trim();
      }
      if (_twitterController.text.trim().isNotEmpty) {
        artistData['twitter'] = _twitterController.text.trim();
      }

      // Add additional social media links
      final List<Map<String, String>> additionalSocials = [];
      for (var social in _additionalSocials) {
        final controller = social['controller'] as TextEditingController?;
        if (controller != null && controller.text.trim().isNotEmpty) {
          additionalSocials.add({
            'platform': social['platform'] ?? 'Social Media',
            'username': controller.text.trim(),
          });
        }
      }
      if (additionalSocials.isNotEmpty) {
        artistData['additionalSocials'] = additionalSocials;
      }

      // Save to Firestore in the 'artist' collection
      await FirebaseFirestore.instance
          .collection('artist')
          .doc(userCredential.user!.uid)
          .set(artistData);

      return true;
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error saving profile: $e';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              errorMessage = 'The password provided is too weak.';
              break;
            case 'email-already-in-use':
              errorMessage = 'An account already exists for that email.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is invalid.';
              break;
            default:
              errorMessage = 'Error creating account: ${e.message}';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
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
                  // Email field
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}), // Update progress
                    decoration: InputDecoration(
                      hintText: 'e.g., artist@example.com',
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
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Password field
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setState(() {}), // Update progress
                    decoration: InputDecoration(
                      hintText: '********',
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
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
                      onPressed: _isUploading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isUploading = true;
                          });

                          String? imageUrl;

                          // Upload profile picture if one is selected
                          if (_profilePicture != null) {
                            imageUrl = await _uploadProfilePicture();
                            if (imageUrl == null) {
                              // Upload failed, don't proceed
                              setState(() {
                                _isUploading = false;
                              });
                              return;
                            }
                          }

                          // Save artist profile to Firestore
                          final success = await _saveArtistProfile(imageUrl);
                          
                          setState(() {
                            _isUploading = false;
                          });

                          if (success) {
                            // Navigate to bottom navbar screen
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BottomNavbarScreen(),
                                ),
                                (route) => false, // Remove all previous routes
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[700],
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Complete Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Already have an account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ArtistLoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF00B4FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
