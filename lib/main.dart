import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants.dart';
import 'screens.dart';
import 'services/theme_provider.dart';
import 'styles/themes.dart';
import 'utils/utils.dart';


void main() async {

  await initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      ///Screen names used from file screens.dart
      initialRoute: Screens.profile,
      routes: {
        Screens.profile: (_) => const ProfileScreen()
      },
    );
  }
}