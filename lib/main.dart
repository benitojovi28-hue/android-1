import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env/env.dart';
import 'core/local/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  if (Env.googleServerClientId.isNotEmpty) {
    try {
      await GoogleSignIn.instance
          .initialize(
            clientId: Platform.isIOS ? Env.googleIosClientId : null,
            serverClientId: Env.googleServerClientId,
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Invalid client IDs, or Play Services unresponsive — Google sign-in
      // button will surface an error on tap instead of blocking app startup.
      debugPrint('GoogleSignIn.initialize failed: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyWorkApp(),
    ),
  );
}
