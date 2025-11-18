import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class AIVAService {
  // AIVA API credentials
  // Sign up at: https://www.aiva.ai/
  // Get your API key from: https://www.aiva.ai/dashboard
  static const String _apiKey = 'YOUR_AIVA_API_KEY_HERE';
  static const String _baseUrl = 'https://api.aiva.ai/v2';

  /// Generate a beat/music track using AIVA
  /// 
  /// Parameters:
  /// - genre: Music genre (e.g., "Hip Hop", "Pop", "Electronic")
  /// - tempo: BPM (beats per minute)
  /// - duration: Duration in seconds (max 180 for free tier)
  /// - mood: Optional mood description
  Future<String> generateBeat({
    required String genre,
    required int tempo,
    int duration = 60, // Default 60 seconds (1 minute)
    String? mood,
  }) async {
    try {
      // AIVA API endpoint for music generation
      final url = Uri.parse('$_baseUrl/generate');

      // Prepare the request body
      final requestBody = {
        'genre': genre,
        'tempo': tempo,
        'duration': duration.clamp(10, 180), // Free tier max: 180 seconds (3 minutes)
        if (mood != null) 'mood': mood,
        'format': 'mp3',
      };

      // Make API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['url'] as String?;

        if (audioUrl != null) {
          // Download the audio file
          return await _downloadAudio(audioUrl);
        } else {
          throw Exception('No audio URL in response');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your AIVA API key.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Free tier allows 3 downloads per month.');
      } else {
        throw Exception('Failed to generate beat: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating beat with AIVA: $e');
    }
  }

  /// Download audio file from URL and save locally
  Future<String> _downloadAudio(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'beat_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      } else {
        throw Exception('Failed to download audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading audio: $e');
    }
  }

  /// Check remaining credits/quota
  Future<Map<String, dynamic>> checkQuota() async {
    try {
      final url = Uri.parse('$_baseUrl/quota');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to check quota: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking quota: $e');
    }
  }
}

