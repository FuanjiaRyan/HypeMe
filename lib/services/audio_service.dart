import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'elevenlabs_service.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _recordingPlayer = AudioPlayer(); // Separate player for recordings
  final ElevenLabsService _elevenLabsService = ElevenLabsService();
  
  String? _beatFilePath;
  String? _recordingFilePath;
  bool _isPlaying = false;
  bool _isPlayingRecording = false;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  VoidCallback? _onRecordingPlaybackComplete;

  /// Generate beat audio using ElevenLabs text-to-speech
  /// 
  /// Note: ElevenLabs is a text-to-speech service, not a music generator.
  /// This converts the beat description to speech audio as a placeholder.
  /// 
  /// Parameters:
  /// - description: Beat description from ElevenLabs
  /// - tempo: BPM (beats per minute)
  /// - genre: Music genre
  /// - mood: Optional mood/instructions
  Future<String> generateBeatAudio({
    required String description,
    required int tempo,
    required String genre,
    String? mood, // Optional mood parameter
  }) async {
    try {
      // Use ElevenLabs to convert beat description to speech
      // This creates an audio file from the description text
      final prompt = _buildPrompt(description, genre, mood, tempo);
      
      _beatFilePath = await _elevenLabsService.textToSpeech(
        text: prompt,
        voiceId: '21m00Tcm4TlvDq8ikWAM', // Default voice (Rachel)
      );
      
      return _beatFilePath!;
    } catch (e) {
      // Fallback to placeholder if ElevenLabs fails
      print('ElevenLabs audio generation failed: $e');
      return await _generatePlaceholderBeat();
    }
  }

  /// Build a prompt for ElevenLabs from description, genre, mood, and tempo
  String _buildPrompt(String description, String genre, String? mood, int tempo) {
    final buffer = StringBuffer();
    
    if (description.isNotEmpty) {
      buffer.write(description);
    }
    
    if (genre.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('. ');
      buffer.write('Genre: $genre');
    }
    
    if (mood != null && mood.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('. ');
      buffer.write('Mood: $mood');
    }
    
    if (buffer.isNotEmpty) buffer.write('. ');
    buffer.write('Tempo: $tempo beats per minute');
    
    return buffer.toString();
  }

  /// Generate placeholder beat file
  /// Note: This creates an empty file as a fallback if ElevenLabs fails.
  Future<String> _generatePlaceholderBeat() async {
    final directory = await getApplicationDocumentsDirectory();
    _beatFilePath = '${directory.path}/beat_${DateTime.now().millisecondsSinceEpoch}.mp3';
    
    // Create a placeholder file
    final file = File(_beatFilePath!);
    await file.create(recursive: true);
    
    // Write empty bytes (this won't play, but prevents errors)
    await file.writeAsBytes([]);
    
    return _beatFilePath!;
  }

  /// Play the beat
  Future<void> playBeat(String filePath) async {
    try {
      // Check if file exists and is not empty
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Beat file does not exist');
      }
      
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Beat file is empty. Please generate a beat first.');
      }
      
      if (_isPlaying) {
        await _player.stop();
      }
      
      await _player.play(DeviceFileSource(filePath));
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }

  /// Stop playing the beat
  Future<void> stopBeat() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Play the recording
  Future<void> playRecording(String filePath) async {
    try {
      // Check if file exists and is not empty
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Recording file does not exist');
      }
      
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Recording file is empty.');
      }
      
      if (_isPlayingRecording) {
        await _recordingPlayer.stop();
      }
      
      // Stop beat if playing
      if (_isPlaying) {
        await _player.stop();
        _isPlaying = false;
      }
      
      await _recordingPlayer.play(DeviceFileSource(filePath));
      _isPlayingRecording = true;
      
      // Listen for completion
      _recordingPlayer.onPlayerComplete.listen((_) {
        _isPlayingRecording = false;
        if (_onRecordingPlaybackComplete != null) {
          _onRecordingPlaybackComplete!();
        }
      });
    } catch (e) {
      _isPlayingRecording = false;
      rethrow;
    }
  }

  /// Stop playing the recording
  Future<void> stopRecordingPlayback() async {
    await _recordingPlayer.stop();
    _isPlayingRecording = false;
  }

  /// Set callback for when recording playback completes
  void onRecordingPlaybackComplete(VoidCallback callback) {
    _onRecordingPlaybackComplete = callback;
  }

  /// Initialize recorder
  Future<void> _initializeRecorder() async {
    if (_isRecorderInitialized) return;
    
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  /// Start recording vocals (with optional beat playback)
  Future<String> startRecording({bool playBeat = false}) async {
    if (_isRecording) {
      throw Exception('Already recording');
    }

    await _initializeRecorder();

    final directory = await getApplicationDocumentsDirectory();
    _recordingFilePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

    // Start recording
    await _recorder.startRecorder(
      toFile: _recordingFilePath,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );

    _isRecording = true;

    // If beat is playing, continue playing while recording
    if (playBeat && _isPlaying) {
      // Beat continues playing
    }

    return _recordingFilePath!;
  }

  /// Stop recording
  Future<String> stopRecording() async {
    if (!_isRecording) {
      throw Exception('Not recording');
    }

    final path = await _recorder.stopRecorder();
    _isRecording = false;

    return path ?? _recordingFilePath!;
  }

  /// Check if currently playing
  bool get isPlaying => _isPlaying;

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Get recording file path
  String? get recordingPath => _recordingFilePath;

  /// Get beat file path
  String? get beatPath => _beatFilePath;

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    await _recordingPlayer.dispose();
    if (_isRecorderInitialized) {
      await _recorder.closeRecorder();
    }
  }
}

