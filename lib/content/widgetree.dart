import 'package:flutter/material.dart';
import 'package:plant_care/content/common/navbar.dart';
import 'package:plant_care/content/page/home.dart';
import 'package:plant_care/content/page/picture.dart';
import 'package:plant_care/content/page/tips.dart';
import 'package:plant_care/notifier/value.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a const navbar as the child so it never rebuilds when the index changes
    return ValueListenableBuilder<int>(
      valueListenable: indexNotifier,
      child: const Navbar(),
      builder: (context, index, navbar) {
        return Scaffold(
          // Use IndexedStack so pages keep their state when switching tabs
          body: IndexedStack(
            index: index,
            children: const [Home(), PicturePage(), Tips()],
          ),
          bottomNavigationBar: navbar,
        );
      },
    );
  }
}
