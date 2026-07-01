import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(
    const ProviderScope(
      child: PrioApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    // Keep the free app usable even if Firebase fails to initialize.
    appLogger.e('Failed to initialize Firebase', error: error, stackTrace: stackTrace);
  }
}
