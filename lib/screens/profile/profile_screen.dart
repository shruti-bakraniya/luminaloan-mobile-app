import 'package:flutter/material.dart';

import '../../widgets/custom_app_bar.dart';

part 'profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  createState() => _ProfileScreen();
}

class _ProfileScreen extends ProfileController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Profile'),
          ],
        ),
      ),
    );
  }
}
