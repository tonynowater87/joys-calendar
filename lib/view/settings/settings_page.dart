import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(child: Text('施工中...')),
      ),
    );
  }
}

enum _ExpandableSetting {
  textScale,
  textDirection,
  locale,
  platform,
  theme,
}
