import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
    final VoidCallback onBack;

  const ProfileScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Profile'),
        actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.settings))],
      ),
      body: const Center(
        child: Text('Profile Screen Content'),
      ),
    );
  }
}
