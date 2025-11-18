import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiService {
  // Gemini API key
  static const String _apiKey = 'AIzaSyD_vJ1FL4nnvqHi11KFKEUrH8X65SsUTU8';
  
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-pro-exp', // Gemini 2.5 Pro experimental version
      apiKey: _apiKey,
    );
  }

  /// Generate a beat description/prompt using Gemini
  Future<Map<String, dynamic>> generateBeatDescription({
    required String genre,
    required int tempo,
    String? mood,
    String? additionalInstructions,
  }) async {
    try {
      final prompt = '''
You are an expert music producer and beat maker. Create a detailed description for generating a ${genre} beat at ${tempo} BPM.

${mood != null ? 'Mood: $mood' : ''}
${additionalInstructions != null ? 'Additional instructions: $additionalInstructions' : ''}

Provide a detailed description in JSON format with the following structure:
{
  "description": "Detailed description of the beat including instruments, rhythm patterns, and style",
  "key_elements": ["element1", "element2", "element3"],
  "structure": "Description of song structure (intro, verse, chorus, etc.)",
  "suggested_lyrics_theme": "Theme for lyrics that would fit this beat"
}

Make it creative and specific to ${genre} genre at ${tempo} BPM.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // Try to extract JSON from the response
      try {
        // Find JSON in the response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          final beatData = jsonDecode(jsonString) as Map<String, dynamic>;
          return beatData;
        }
      } catch (e) {
        // If JSON parsing fails, return structured data from text
      }

      // Fallback: return structured response
      return {
        'description': text,
        'key_elements': ['Drums', 'Bass', 'Melody'],
        'structure': 'Standard ${genre} structure',
        'suggested_lyrics_theme': 'Match the ${genre} vibe',
      };
    } catch (e) {
      throw Exception('Failed to generate beat description: $e');
    }
  }

  /// Generate lyrics suggestions based on the beat
  Future<String> generateLyricsSuggestion({
    required String theme,
    required String genre,
    int? verseCount,
  }) async {
    try {
      final prompt = '''
You are a professional songwriter. Write ${verseCount ?? 2} verses of lyrics for a ${genre} song.

Theme: $theme
Style: ${genre}

Make it catchy, creative, and suitable for the ${genre} genre. Return only the lyrics, no explanations.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No lyrics generated';
    } catch (e) {
      throw Exception('Failed to generate lyrics: $e');
    }
  }

  /// Analyze the recording and provide feedback
  Future<Map<String, dynamic>> analyzeRecording({
    required String transcription,
    required String beatDescription,
  }) async {
    try {
      final prompt = '''
Analyze this vocal recording transcription and provide feedback:

Recording: $transcription
Beat Description: $beatDescription

Provide feedback in JSON format:
{
  "rhythm_match": "How well the vocals match the beat rhythm",
  "suggestions": ["suggestion1", "suggestion2"],
  "strengths": ["strength1", "strength2"],
  "overall_rating": "rating out of 10"
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        }
      } catch (e) {
        // Fallback
      }

      return {
        'rhythm_match': 'Good',
        'suggestions': ['Keep practicing'],
        'strengths': ['Good energy'],
        'overall_rating': '7/10',
      };
    } catch (e) {
      throw Exception('Failed to analyze recording: $e');
    }
  }

  /// Generate a creative title for the creation
  Future<String> generateTitle({
    required String genre,
    required String theme,
  }) async {
    try {
      final prompt = '''
Generate a catchy, creative title for a ${genre} song with the theme: $theme

Return only the title, nothing else. Make it short (2-5 words) and memorable.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Untitled';
    } catch (e) {
      return 'Untitled';
    }
  }
}

