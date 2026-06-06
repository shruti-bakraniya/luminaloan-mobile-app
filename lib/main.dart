import 'package:flutter/material.dart';

import 'constants.dart';
import 'screens.dart';
import 'styles/themes.dart';
import 'utils/utils.dart';


void main() async {

  await initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: lightTheme,
      navigatorKey: navigatorKey,
      ///Screen names used from file screens.dart
      initialRoute: Screens.profile,
      routes: {
        Screens.profile: (_) => const ProfileScreen()
      },
    );
  }
}