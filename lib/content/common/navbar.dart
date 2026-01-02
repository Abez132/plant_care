import 'package:flutter/material.dart';
import 'package:plant_care/notifier/value.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: indexNotifier,
      builder: (context, value, child) {
        return NavigationBar(
          height: 70,
          backgroundColor: Colors.white.withOpacity(0.95),
          indicatorColor: const Color(0xFF9ED9A3),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),

          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt_rounded),
              label: "Scan",
            ),
            NavigationDestination(
              icon: Icon(Icons.tips_and_updates_outlined),
              selectedIcon: Icon(Icons.tips_and_updates_rounded),
              label: "Tips",
            ),
          ],

          onDestinationSelected: (int value) {
            indexNotifier.value = value;
          },
          selectedIndex: value,
        );
      },
    );
  }
}
