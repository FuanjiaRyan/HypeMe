# Beatoven Integration Setup Guide

## Beatoven Free Tier Overview

✅ **50 FREE Credits for Testing!**
- Get 50 free credits when you sign up
- Royalty-free music
- Text-to-music generation
- Video-to-music generation
- Commercial use allowed (with proper plan)

## Why Beatoven?

🎵 **Best Free Option:**
- **50 free credits** (vs AIVA's 3/month)
- **Royalty-free** music
- **Commercial use** allowed (with paid plans)
- **Fast generation** (usually 30-60 seconds)
- **Text-to-music** - perfect for our use case!

## Setup Instructions

### Step 1: Create Beatoven Account

1. Visit: https://www.beatoven.ai/
2. Click "Sign Up" or "Get Started"
3. Create a free account
4. Verify your email

### Step 2: Get API Key

1. Log in to your Beatoven account
2. Go to your **Profile**
3. Click on **API** option
4. Click **Generate Token**
5. Copy your API key (you get 50 free credits!)

### Step 3: Add API Key to App

1. Open `lib/services/beatoven_service.dart`
2. Replace `YOUR_BEATOVEN_API_KEY_HERE` with your actual API key:

```dart
static const String _apiKey = 'your-actual-beatoven-api-key';
```

### Step 4: Enable Beatoven in Audio Service

1. Open `lib/services/audio_service.dart`
2. The service is already set to use Beatoven by default:

```dart
String _musicService = 'beatoven'; // Already set!
```

**Options:**
- `'beatoven'` - Use Beatoven API (recommended - 50 free credits)
- `'aiva'` - Use AIVA API (3 free downloads/month)
- `'placeholder'` - Use placeholder for testing

## Usage

### How It Works

1. **User selects genre, tempo, mood**
2. **Gemini generates beat description** (creative AI description)
3. **Beatoven generates actual audio** from the description
4. **User records vocals** over the beat
5. **Upload to feed**

### Free Credits

- **50 free credits** when you sign up
- Each beat generation uses 1 credit
- Check remaining credits using `checkCredits()` method

### For Production/Commercial Use

After free credits, Beatoven offers paid plans:
- Check pricing at: https://www.beatoven.ai/pricing
- All generated music is **royalty-free**

## API Features

✅ **Text-to-Music**: Generate from text prompts
✅ **Genre Support**: Hip Hop, Pop, Electronic, Rock, etc.
✅ **Mood Control**: Energetic, Chill, Dark, Uplifting, etc.
✅ **Tempo Control**: Adjustable BPM
✅ **Duration Control**: Custom track length
✅ **Royalty-Free**: Use in commercial projects

## Testing

1. **With Beatoven (Real API):**
   - Set `_musicService = 'beatoven'` in `audio_service.dart`
   - Add your API key
   - Generate beats (50 free credits!)

2. **Without API (Placeholder):**
   - Set `_musicService = 'placeholder'` in `audio_service.dart`
   - Creates placeholder files for testing
   - No API calls, unlimited testing

## Error Handling

The app will automatically:
- Fall back to placeholder if Beatoven API fails
- Show error messages for:
  - Invalid API key
  - Insufficient credits
  - Network errors
  - Generation timeout

## API Documentation

For more details:
- Beatoven API Docs: https://www.beatoven.ai/api
- GitHub Examples: https://github.com/Beatoven/public-api
- Contact: hello@beatoven.ai

## Comparison: Beatoven vs AIVA

| Feature | Beatoven | AIVA |
|---------|----------|------|
| **Free Credits** | 50 credits | 3 downloads/month |
| **Royalty-Free** | ✅ Yes | ✅ Yes (with attribution) |
| **Commercial Use** | ✅ Yes (with plan) | ⚠️ Non-commercial only (free) |
| **Generation Speed** | ~30-60 seconds | ~2-5 minutes |
| **Text-to-Music** | ✅ Yes | ✅ Yes |
| **Best For** | Development & Testing | Non-commercial projects |

## Recommendation

**Use Beatoven** for:
- ✅ Development and testing (50 free credits)
- ✅ Commercial projects (with paid plan)
- ✅ Faster generation
- ✅ More flexibility

**Use AIVA** for:
- ✅ Non-commercial projects
- ✅ When you need only 3 tracks/month
- ✅ When attribution is acceptable

