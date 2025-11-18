# Gemini AI Integration Setup Guide

## Getting Your Gemini API Key

1. **Visit Google AI Studio**: https://makersuite.google.com/app/apikey
2. **Sign in** with your Google account
3. **Create a new API key** or use an existing one
4. **Copy the API key**

## Setting Up the API Key

1. Open `lib/services/gemini_service.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:

```dart
static const String _apiKey = 'your-actual-api-key-here';
```

## Important Notes

### Current Implementation

The current implementation uses Gemini for:
- ✅ **Beat Description Generation**: Creates detailed descriptions of beats
- ✅ **Title Generation**: Suggests creative titles
- ✅ **Lyrics Suggestions**: Generates lyrics ideas
- ✅ **Recording Analysis**: Provides feedback on recordings

### Audio Generation Limitation

**Gemini does NOT directly generate audio files**. The current implementation:
- Uses Gemini to create detailed beat descriptions
- Creates placeholder audio files (you need to replace this)

### To Add Real Audio Generation

You have two options:

#### Option 1: Use a Music Generation API
Integrate with services like:
- **Mubert API**: https://mubert.com/developers
- **Suno AI**: https://suno.ai
- **AIVA**: https://www.aiva.ai/

Replace the `generateBeatAudio` method in `lib/services/audio_service.dart`:

```dart
Future<String> generateBeatAudio({
  required String description,
  required int tempo,
  required String genre,
}) async {
  // Call your music generation API here
  // Use the description from Gemini as a prompt
  final response = await http.post(
    Uri.parse('YOUR_MUSIC_API_ENDPOINT'),
    body: {
      'prompt': description,
      'tempo': tempo.toString(),
      'genre': genre,
    },
  );
  
  // Download and save the audio file
  // Return the file path
}
```

#### Option 2: Use Pre-generated Beat Samples
- Create a library of beat samples organized by genre/tempo
- Select appropriate sample based on user's choices
- This is simpler but less flexible

## Testing

1. **Run the app**: `flutter run`
2. **Navigate to Upload → AI Beat Creator**
3. **Select a genre** (required)
4. **Optionally enter mood/instructions**
5. **Adjust tempo**
6. **Click "Generate Beat"**
7. **Wait for Gemini to generate description**
8. **Record vocals** while beat plays
9. **Upload to feed**

## Troubleshooting

### "Failed to generate beat description"
- Check your API key is correct
- Ensure you have internet connection
- Check API quota limits

### "Error starting recording"
- Check microphone permissions in app settings
- Ensure device has microphone access

### Audio not playing
- Check audio file exists
- Verify file path is correct
- Check device volume

## Next Steps

1. ✅ Get Gemini API key
2. ✅ Add API key to `gemini_service.dart`
3. ⚠️ Replace audio generation with real API (Mubert, Suno, etc.)
4. ✅ Test the full flow
5. ✅ Deploy!

## Cost Considerations

- **Gemini API**: Free tier available (60 requests/minute)
- **Music Generation API**: Varies by service
- **Firebase Storage**: Pay per GB stored

## Support

For Gemini API issues: https://ai.google.dev/docs
For Flutter audio: https://pub.dev/packages/record

