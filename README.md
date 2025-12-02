# Flutter Video Call App

A modern video calling application built with Flutter, featuring real-time chat, friend management, and video calls using Appwrite and ZegoCloud.

## Features

✨ **Authentication** - Email/password signup and login  
💬 **Real-time Chat** - One-on-one messaging with live updates  
📹 **Video Calls** - High-quality video calling via ZegoCloud  
👥 **Friend System** - Add friends, manage requests  
🎨 **Messenger UI** - Beautiful gradient design inspired by Meta Messenger  
🌓 **Dark Mode** - Full dark mode support

## Tech Stack

- **Framework**: Flutter 3.5.4+
- **Backend**: Appwrite (Auth, Database, Realtime)
- **Video SDK**: ZegoCloud UIKit
- **State Management**: Provider
- **UI**: Material Design 3 with custom theming

## Prerequisites

Before running this app, you need:

### 1. Flutter SDK
```bash
flutter --version  # Should be 3.5.0 or higher
```

### 2. Appwrite Setup

**Option A: Appwrite Cloud (Recommended)**
1. Go to https://cloud.appwrite.io
2. Create a new account
3. Create a new project
4. Note your **Project ID** and **Endpoint**

**Option B: Self-hosted**
```bash
docker run -d --name appwrite \
  -p 80:80 -p 443:443 \
  appwrite/appwrite
```

### 3. Configure Appwrite Collections

In your Appwrite console, create a database called `main_db` with these collections:

#### Collection: `users`
- `email` (String, Required)
- `name` (String, Required)
- `avatarUrl` (String, Optional)
- `friends` (String[], Required, Default: [])
- `createdAt` (String, Required)
- `lastSeen` (String, Optional)
- `isOnline` (Boolean, Required, Default: false)

#### Collection: `messages`
- `senderId` (String, Required)
- `receiverId` (String, Required)
- `text` (String, Required)
- `type` (String, Required, Default: "text")
- `timestamp` (String, Required)
- `isRead` (Boolean, Required, Default: false)

#### Collection: `friend_requests`
- `fromUserId` (String, Required)
- `toUserId` (String, Required)
- `status` (String, Required, Default: "pending")
- `timestamp` (String, Required)

### 4. ZegoCloud Setup

1. Go to https://www.zegocloud.com
2. Sign up for free account
3. Create a new project
4. Get your **App ID** and **App Sign**

## Installation

### 1. Clone and Install Dependencies

```bash
cd demo
flutter pub get
```

### 2. Configure Credentials

Edit `lib/core/constants/app_constants.dart`:

```dart
// Appwrite Configuration
static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1'; // Or your self-hosted URL
static const String appwriteProjectId = 'YOUR_PROJECT_ID_HERE';

// Database and Collections (already configured)
static const String databaseId = 'main_db';
static const String usersCollectionId = 'users';
static const String messagesCollectionId = 'messages';
static const String friendRequestsCollectionId = 'friend_requests';

// ZegoCloud Configuration
static const int zegoAppId = YOUR_APP_ID_HERE; // Replace with your App ID (number)
static const String zegoAppSign = 'YOUR_APP_SIGN_HERE'; // Replace with your App Sign
```

### 3. Add Font (Optional but Recommended)

Download Inter font from Google Fonts and place in `assets/fonts/`:
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf
- Inter-Bold.ttf

Or comment out the fonts section in `pubspec.yaml` if skipping.

## Running the App

```bash
flutter run
```

For Android:
```bash
flutter run -d android
```

For iOS:
```bash
flutter run -d ios
```

## App Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants (colors, strings, config)
│   ├── services/        # Appwrite service initialization
│   └── utils/           # Utilities (validators, formatters, theme)
├── data/
│   ├── models/          # Data models (User, Message, FriendRequest)
│   └── services/        # Business logic (AuthService, DatabaseService)
├── presentation/
│   ├── providers/       # State management (Auth, Chat, Friends)
│   ├── screens/         # UI screens
│   │   ├── auth/        # Login, Register
│   │   ├── home/        # Home with tabs
│   │   ├── chat/        # Chat list, Chat detail
│   │   ├── friends/     # Friends list, Add friend
│   │   ├── profile/     # Profile, Edit profile
│   │   └── call/        # Video call
│   └── widgets/         # Reusable widgets
├── app.dart             # Root app widget
└── main.dart            # Entry point
```

## Usage

### 1. Create Account
- Launch app
- Tap "Sign Up"
- Enter name, email, and password

### 2. Add Friends
- Go to Friends tab
- Tap "+" icon
- Search by email
- Send friend request

### 3. Start Chatting
- Go to Chats tab
- Tap on a friend
- Type and send messages

### 4. Video Call
- Open a chat
- Tap video camera icon in app bar
- Wait for your friend to join

## Troubleshooting

**"Failed to connect to Appwrite"**
- Check your internet connection
- Verify `appwriteEndpoint` and `appwriteProjectId` in `app_constants.dart`
- Ensure Appwrite server is running (if self-hosted)

**"ZegoCloud initialization failed"**
- Verify your `zegoAppId` and `zegoAppSign`
- Check ZegoCloud dashboard for project status
- Ensure app ID is a number, not a string

**"Collection not found"**
- Create all required collections in Appwrite console
- Match collection IDs exactly with `app_constants.dart`

**Build errors**
```bash
flutter clean
flutter pub get
flutter run
```

## TODO / Future Enhancements

- [ ] Image sharing in chat
- [ ] Push notifications for messages
- [ ] Group chats
- [ ] Audio-only calls
- [ ] Message reactions
- [ ] User status/about
- [ ] Block/report users

## License

This project is for educational purposes.

## Credits

- UI design inspired by Meta Messenger
- Backend powered by [Appwrite](https://appwrite.io)
- Video calling by [ZegoCloud](https://www.zegocloud.com)
