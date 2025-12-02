import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/appwrite_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/friends_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Appwrite
  AppwriteService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Check auth status after app starts
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      await context.read<AuthProvider>().checkAuthStatus();
    }
  });
}

// Global navigator key for accessing context outside widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
