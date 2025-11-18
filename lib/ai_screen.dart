import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'all_artist_post.dart';
import 'services/elevenlabs_service.dart';
import 'services/audio_service.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  bool _isGeneratingBeat = false;
  bool _isRecording = false;
  bool _isPlayingBeat = false;
  bool _isPlayingRecording = false;
  bool _isUploading = false;
  String? _generatedBeatUrl;
  String? _recordingUrl;
  String? _selectedGenre;
  double _tempo = 120.0;
  String? _beatDescription;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  
  late final ElevenLabsService _elevenLabsService;
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _elevenLabsService = ElevenLabsService();
    _audioService = AudioService();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _moodController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Beat Creator',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF00B4FF).withOpacity(0.2),
                        const Color(0xFF7B2CBF).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00B4FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4FF).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF00B4FF),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Beats with AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate unique beats and sing along with AI-powered music creation',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Beat Generation Section
                const Text(
                  'Generate Beat',
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre Selection
                      const Text(
                        'Select Genre',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Hip Hop',
                          'R&B',
                          'Pop',
                          'Electronic',
                          'Rock',
                          'Jazz',
                        ].map((genre) {
                          return FilterChip(
                            label: Text(genre),
                            selected: _selectedGenre == genre,
                            onSelected: (selected) {
                              setState(() {
                                _selectedGenre = selected ? genre : null;
                              });
                            },
                            selectedColor: const Color(0xFF00B4FF),
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: Colors.grey[800],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // Mood/Additional Instructions
                      const Text(
                        'Mood/Instructions (Optional)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _moodController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g., energetic, chill, dark, uplifting',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tempo Selection
                      const Text(
                        'Tempo (BPM)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _tempo,
                        min: 60,
                        max: 180,
                        divisions: 24,
                        label: '${_tempo.toInt()} BPM',
                        activeColor: const Color(0xFF00B4FF),
                        onChanged: (value) {
                          setState(() {
                            _tempo = value;
                          });
                        },
                      ),
                      Text(
                        '${_tempo.toInt()} BPM',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Upload Your Own Beat Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isGeneratingBeat
                              ? null
                              : () {
                                  _uploadOwnBeat();
                                },
                          icon: const Icon(Icons.upload_file),
                          label: const Text(
                            'Upload Your Own Beat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFF00B4FF),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledForegroundColor: Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider with "OR" text
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[700],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[700],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingBeat
                              ? null
                              : () {
                                  _generateBeat();
                                },
                          icon: _isGeneratingBeat
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isGeneratingBeat
                                ? 'Generating Beat...'
                                : 'Generate Beat',
                            style: const TextStyle(
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
                            disabledBackgroundColor: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Generated/Uploaded Beat Player
                if (_generatedBeatUrl != null) ...[
                  Text(
                    _beatDescription == 'Custom uploaded beat'
                        ? 'Your Beat'
                        : 'Generated Beat',
                    style: const TextStyle(
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.music_note,
                              color: Color(0xFF00B4FF),
                              size: 60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: () {},
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B4FF),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isPlayingBeat ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: _generatedBeatUrl == null
                                    ? null
                                    : () async {
                                        try {
                                          if (_isPlayingBeat) {
                                            await _audioService.stopBeat();
                                            setState(() {
                                              _isPlayingBeat = false;
                                            });
                                          } else {
                                            await _audioService.playBeat(_generatedBeatUrl!);
                                            setState(() {
                                              _isPlayingBeat = true;
                                            });
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error playing beat: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                                duration: const Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                          setState(() {
                                            _isPlayingBeat = false;
                                          });
                                        }
                                      },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                // Sing with Beat Section
                const Text(
                  'Sing with Beat',
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (_generatedBeatUrl == null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Generate a beat first to sing along',
                                  style: TextStyle(
                                    color: Colors.orange[200],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        const Text(
                          'Record your vocals over the generated beat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Play Beat While Recording Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPlayingBeat ? Icons.volume_up : Icons.volume_off,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPlayingBeat ? 'Beat Playing' : 'Beat Stopped',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: _isPlayingBeat,
                              onChanged: (value) {
                                setState(() {
                                  _isPlayingBeat = value;
                                });
                              },
                              activeColor: const Color(0xFF00B4FF),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isRecording
                                  ? Colors.red
                                  : const Color(0xFF00B4FF),
                              width: 4,
                            ),
                            color: _isRecording
                                ? Colors.red.withOpacity(0.2)
                                : const Color(0xFF00B4FF).withOpacity(0.2),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: _isRecording ? Colors.red : Colors.white,
                              size: 50,
                            ),
                            onPressed: () async {
                              if (_isRecording) {
                                // Stop recording
                                try {
                                  final recordingPath = await _audioService.stopRecording();
                                  setState(() {
                                    _isRecording = false;
                                    _recordingUrl = recordingPath;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error stopping recording: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // Start recording
                                try {
                                  await _audioService.startRecording(
                                    playBeat: _isPlayingBeat,
                                  );
                                  setState(() {
                                    _isRecording = true;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error starting recording: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRecording ? 'Recording...' : 'Tap to Record',
                          style: TextStyle(
                            color: _isRecording ? Colors.red : Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_recordingUrl != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Recording Saved',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Your vocals have been recorded',
                                        style: TextStyle(
                                          color: Colors.green[200],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isPlayingRecording
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    if (_recordingUrl == null) return;
                                    
                                    try {
                                      if (_isPlayingRecording) {
                                        // Stop playing recording
                                        await _audioService.stopRecordingPlayback();
                                        setState(() {
                                          _isPlayingRecording = false;
                                        });
                                      } else {
                                        // Play recording
                                        await _audioService.playRecording(_recordingUrl!);
                                        setState(() {
                                          _isPlayingRecording = true;
                                        });
                                        
                                        // Listen for playback completion
                                        _audioService.onRecordingPlaybackComplete(() {
                                          if (mounted) {
                                            setState(() {
                                              _isPlayingRecording = false;
                                            });
                                          }
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error playing recording: $e'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                      setState(() {
                                        _isPlayingRecording = false;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Save & Share Section
                if (_generatedBeatUrl != null && _recordingUrl != null) ...[
                  const Text(
                    'Post Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter a title for your creation',
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
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () {
                              _uploadAndShare();
                            },
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.upload),
                      label: Text(
                        _isUploading ? 'Uploading...' : 'Upload to Feed',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2CBF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadOwnBeat() async {
    try {
      // Pick audio file from device
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        
        // Check if file exists
        if (await file.exists()) {
          setState(() {
            _generatedBeatUrl = filePath;
            _beatDescription = 'Custom uploaded beat';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Beat uploaded successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File not found. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading beat: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _generateBeat() async {
    if (_selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a genre first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingBeat = true;
    });

    try {
      // Use 11ElevenLabs to generate beat description
      final beatData = await _elevenLabsService.generateBeatDescription(
        genre: _selectedGenre!,
        tempo: _tempo.toInt(),
        mood: _moodController.text.trim().isEmpty 
            ? null 
            : _moodController.text.trim(),
      );

      setState(() {
        _beatDescription = beatData['description'] as String?;
      });

      // Generate audio file using ElevenLabs text-to-speech
      String beatFilePath;
      bool isPlaceholder = false;
      
      try {
        beatFilePath = await _audioService.generateBeatAudio(
          description: _beatDescription ?? '',
          tempo: _tempo.toInt(),
          genre: _selectedGenre!,
          mood: _moodController.text.trim().isEmpty 
              ? null 
              : _moodController.text.trim(),
        );
        
        // Check if it's a placeholder (empty file)
        final file = File(beatFilePath);
        if (await file.exists() && await file.length() == 0) {
          isPlaceholder = true;
        }
      } catch (e) {
        // If generation fails, show error but continue
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Beat generation failed: $e. Using placeholder.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        isPlaceholder = true;
        beatFilePath = await _audioService.generateBeatAudio(
          description: _beatDescription ?? '',
          tempo: _tempo.toInt(),
          genre: _selectedGenre!,
          mood: _moodController.text.trim().isEmpty 
              ? null 
              : _moodController.text.trim(),
        );
      }

      // Generate suggested title
      final title = await _elevenLabsService.generateTitle(
        genre: _selectedGenre!,
        theme: beatData['suggested_lyrics_theme'] as String? ?? 'Music',
      );

      setState(() {
        _isGeneratingBeat = false;
        _generatedBeatUrl = beatFilePath;
        if (_titleController.text.isEmpty) {
          _titleController.text = title;
        }
      });

      if (mounted) {
        if (isPlaceholder) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Beat description generated! Note: Audio generation may take a moment.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Beat generated! ${beatData['description']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingBeat = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating beat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAndShare() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your creation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
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

      // Get artist data for the post
      final artistDoc = await FirebaseFirestore.instance
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

      // Upload beat and recording to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      String? beatDownloadUrl;
      String? recordingDownloadUrl;

      // Upload beat file
      if (_generatedBeatUrl != null && File(_generatedBeatUrl!).existsSync()) {
        final beatFile = File(_generatedBeatUrl!);
        final beatRef = storageRef.child('ai_beats/beat_$timestamp.mp3');
        await beatRef.putFile(beatFile);
        beatDownloadUrl = await beatRef.getDownloadURL();
      }

      // Upload recording file
      if (_recordingUrl != null && File(_recordingUrl!).existsSync()) {
        final recordingFile = File(_recordingUrl!);
        // Get file extension from path
        final extension = _recordingUrl!.split('.').last;
        final recordingRef = storageRef.child('ai_recordings/recording_$timestamp.$extension');
        await recordingRef.putFile(recordingFile);
        recordingDownloadUrl = await recordingRef.getDownloadURL();
      }

      // Create post document in Firestore
      final postData = {
        'artistId': user.uid,
        'artistName': artistName,
        'profileImageUrl': profileImageUrl,
        'title': _titleController.text.trim(),
        'type': 'ai_creation',
        'beatUrl': beatDownloadUrl,
        'recordingUrl': recordingDownloadUrl,
        'genre': _selectedGenre ?? 'Unknown',
        'tempo': _tempo.toInt(),
        'beatDescription': _beatDescription,
        'likes': 0,
        'views': 0,
        'comments': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('posts').add(postData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your creation has been uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to all artist posts screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AllArtistPostScreen(showBackButton: false),
          ),
          (route) => route.isFirst, // Keep only the first route (home)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
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
}
