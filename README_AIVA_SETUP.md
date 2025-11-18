# AIVA Integration Setup Guide

## AIVA Free Tier Overview

✅ **FREE Plan Available:**
- 3 downloads per month
- Up to 3 minutes per track
- MP3 and MIDI formats
- Non-commercial use only
- Must credit AIVA

## Setup Instructions

### Step 1: Create AIVA Account

1. Visit: https://www.aiva.ai/
2. Click "Sign Up" or "Get Started"
3. Create a free account
4. Verify your email

### Step 2: Get API Key

1. Log in to your AIVA account
2. Go to Dashboard: https://www.aiva.ai/dashboard
3. Navigate to API Settings
4. Generate or copy your API key

### Step 3: Add API Key to App

1. Open `lib/services/aiva_service.dart`
2. Replace `YOUR_AIVA_API_KEY_HERE` with your actual API key:

```dart
static const String _apiKey = 'your-actual-aiva-api-key';
```

### Step 4: Enable AIVA in Audio Service

1. Open `lib/services/audio_service.dart`
2. Change `_useAIVA` to `true`:

```dart
bool _useAIVA = true; // Enable AIVA API
```

## Usage

### Free Tier Limitations

⚠️ **Important Notes:**
- Only 3 downloads per month on free tier
- Tracks limited to 3 minutes maximum
- Non-commercial use only
- Must credit AIVA when using the music

### For Production/Commercial Use

Consider upgrading to:
- **Standard Plan**: €15/month - 15 downloads, 5 minutes, limited monetization
- **Pro Plan**: €49/month - 300 downloads, 5.5 minutes, full ownership

## Testing

1. **With AIVA (Real API):**
   - Set `_useAIVA = true` in `audio_service.dart`
   - Add your API key
   - Generate beats (limited to 3/month on free tier)

2. **Without AIVA (Placeholder):**
   - Set `_useAIVA = false` in `audio_service.dart`
   - Creates placeholder files for testing
   - No API calls, unlimited testing

## Error Handling

The app will automatically:
- Fall back to placeholder if AIVA API fails
- Show error messages for:
  - Invalid API key
  - Rate limit exceeded (3/month limit)
  - Network errors

## API Documentation

For more details, visit:
- AIVA API Docs: https://www.aiva.ai/api-documentation
- AIVA Pricing: https://www.aiva.ai/pricing

## Alternative: Mubert API

If you prefer Mubert:
- 3-month free trial
- 1,000 API calls
- After trial: Paid plans start at $499/month

To use Mubert instead:
1. Create `lib/services/mubert_service.dart` (similar structure)
2. Update `audio_service.dart` to use Mubert
3. Get API key from: https://mubert.com/developers

