import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  // 11ElevenLabs API credentials
  static const String _apiKey = 'sk_6b2e82361364d12a07d7552dcbce8bed2c984ce5be6ccd99';
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  /// Generate creative beat description using AI
  /// Note: 11ElevenLabs is primarily for text-to-speech, but we can use it creatively
  Future<Map<String, dynamic>> generateBeatDescription({
    required String genre,
    required int tempo,
    String? mood,
  }) async {
    // Since 11ElevenLabs doesn't generate text descriptions,
    // we'll create a structured description based on the inputs
    final description = _createBeatDescription(genre, tempo, mood);
    
    final keyElements = _getKeyElements(genre);
    final structure = _getStructure(genre);
    final lyricsTheme = _getLyricsTheme(genre, mood);

    return {
      'description': description,
      'key_elements': keyElements,
      'structure': structure,
      'suggested_lyrics_theme': lyricsTheme,
    };
  }

  /// Create a detailed beat description
  String _createBeatDescription(String genre, int tempo, String? mood) {
    final buffer = StringBuffer();
    
    buffer.write('A ${tempo} BPM $genre beat');
    if (mood != null && mood.isNotEmpty) {
      buffer.write(' with a $mood mood');
    }
    buffer.write('. ');
    
    // Add genre-specific details
    switch (genre.toLowerCase()) {
      case 'hip hop':
        buffer.write('Features heavy 808 bass, crisp hi-hats, and a catchy melody. Perfect for rap and hip-hop vocals.');
        break;
      case 'r&b':
        buffer.write('Smooth and soulful with warm pads, groovy basslines, and subtle percussion. Ideal for R&B vocals.');
        break;
      case 'pop':
        buffer.write('Catchy and energetic with bright synths, punchy drums, and memorable hooks. Great for pop vocals.');
        break;
      case 'electronic':
        buffer.write('Driving and dynamic with electronic elements, synthesizers, and modern production techniques.');
        break;
      case 'rock':
        buffer.write('Powerful and energetic with distorted guitars, strong drums, and anthemic qualities.');
        break;
      case 'jazz':
        buffer.write('Smooth and sophisticated with jazz chords, swing rhythms, and melodic improvisation.');
        break;
      default:
        buffer.write('Features a strong rhythm section, melodic elements, and dynamic arrangement.');
    }
    
    return buffer.toString();
  }

  /// Get key elements for the genre
  List<String> _getKeyElements(String genre) {
    switch (genre.toLowerCase()) {
      case 'hip hop':
        return ['808 Bass', 'Hi-Hats', 'Melody', 'Kick Drum'];
      case 'r&b':
        return ['Warm Pads', 'Bassline', 'Percussion', 'Smooth Chords'];
      case 'pop':
        return ['Bright Synths', 'Punchy Drums', 'Hooks', 'Catchy Melody'];
      case 'electronic':
        return ['Synthesizers', 'Electronic Elements', 'Modern Production', 'Driving Rhythm'];
      case 'rock':
        return ['Distorted Guitars', 'Strong Drums', 'Power Chords', 'Energetic Feel'];
      case 'jazz':
        return ['Jazz Chords', 'Swing Rhythm', 'Melodic Lines', 'Sophisticated Harmony'];
      default:
        return ['Drums', 'Bass', 'Melody', 'Harmony'];
    }
  }

  /// Get structure description
  String _getStructure(String genre) {
    return 'Standard $genre structure with intro, verse, chorus, and outro sections. Dynamic arrangement with build-ups and drops.';
  }

  /// Get lyrics theme
  String _getLyricsTheme(String genre, String? mood) {
    final theme = StringBuffer();
    if (mood != null && mood.isNotEmpty) {
      theme.write('$mood ');
    }
    theme.write('$genre vibe');
    return theme.toString();
  }

  /// Generate title suggestion
  Future<String> generateTitle({
    required String genre,
    required String theme,
  }) async {
    // Create title based on genre and theme
    final titles = [
      '$genre Vibes',
      '$theme $genre',
      '$genre Dreams',
      '$theme Beat',
      '$genre Flow',
    ];
    return titles[DateTime.now().millisecond % titles.length];
  }

  /// Generate lyrics suggestion
  Future<String> generateLyricsSuggestion({
    required String theme,
    required String genre,
    int? verseCount,
  }) async {
    final buffer = StringBuffer();
    final count = verseCount ?? 2;
    
    for (int i = 0; i < count; i++) {
      buffer.writeln('Verse ${i + 1}:');
      buffer.writeln('This is a $genre song');
      buffer.writeln('With a $theme feel');
      buffer.writeln('The rhythm flows so smooth');
      buffer.writeln('It makes you want to move');
      buffer.writeln('');
    }
    
    return buffer.toString();
  }

  /// Text-to-speech conversion (bonus feature)
  Future<String> textToSpeech({
    required String text,
    String voiceId = '21m00Tcm4TlvDq8ikWAM', // Default voice
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/text-to-speech/$voiceId');
      
      final requestBody = {
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to generate speech: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating speech: $e');
    }
  }
}
