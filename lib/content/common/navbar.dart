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
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              label: "pics",
            ),
            NavigationDestination(
              icon: Icon(Icons.tips_and_updates_outlined),
              label: "Home",
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.person_outline_outlined),
            //   label: "Login",
            // ),
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
