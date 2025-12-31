import 'package:flutter/material.dart';
import 'package:plant_care/content/common/navbar.dart';
import 'package:plant_care/content/page/home.dart';
import 'package:plant_care/content/page/picture.dart';
import 'package:plant_care/content/page/profile.dart';
import 'package:plant_care/content/page/tips.dart';
import 'package:plant_care/notifier/value.dart';

List<Widget> pages = [Home(), Picture(), Tips(), Profile()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      bottomNavigationBar: Navbar(),
      body: ValueListenableBuilder(
        valueListenable: indexNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),

      // ValueListenableBuilder(
      //   valueListenable: indexNotifier,
      //   builder: (context, value, child) {
      //     return pages.elementAt(indexNotifier.value);
      //   },
      // ),
    );
  }
}
