import 'package:flutter/material.dart';
import 'package:plant_care/notifier/value.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: indexNotifier,
      builder: (context, value, _) {
        return NavigationBar(
          height: 70,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 250),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt_rounded),
              label: 'Identify',
            ),
            NavigationDestination(
              icon: Icon(Icons.tips_and_updates_outlined),
              selectedIcon: Icon(Icons.tips_and_updates_rounded),
              label: 'Tips',
            ),
          ],
          onDestinationSelected: (int idx) {
            indexNotifier.value = idx;
          },
          selectedIndex: value,
        );
      },
    );
  }
}
