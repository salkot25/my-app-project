import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling for duplicate apps
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Firebase is already initialized, which is fine
      debugPrint('Firebase already initialized, continuing...');
    } else {
      // Some other Firebase error occurred, rethrow it
      rethrow;
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}
