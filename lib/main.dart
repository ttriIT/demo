import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/appwrite_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/friends_provider.dart';
import 'presentation/providers/call_provider.dart';
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
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: Builder(
        builder: (context) {
          return Listener(
            onPointerDown: (_) {
               context.read<AuthProvider>().resetInactivityTimer();
            },
            onPointerMove: (_) {
               // Throttle this if needed, but for now simple reset
               context.read<AuthProvider>().resetInactivityTimer();
            },
            child: const MyApp(),
          );
        }
      ),
    ),
  );

  // Check auth status after app starts
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthStatus();
      
      // Initialize ZegoUIKit if user is authenticated
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        final callProvider = context.read<CallProvider>();
        try {
          await callProvider.initialize(
            userId: authProvider.currentUser!.id,
            userName: authProvider.currentUser!.name,
          );
        } catch (e) {
          print('Failed to initialize ZegoUIKit: $e');
        }
      }
    }
  });
}

// Global navigator key for accessing context outside widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
