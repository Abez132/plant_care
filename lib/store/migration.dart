import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
class DataMigration {
  static Future<void> clearAllPlantData() async {
    try {
      final dir = await _safeDocumentsDirectory();
      final file = File('${dir.path}/plants.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing plant data: $e');
    }
  }
  static Future<void> migratePlantData() async {
    try {
      final dir = await _safeDocumentsDirectory();
      final file = File('${dir.path}/plants.json');

      if (!await file.exists()) return;

      final content = await file.readAsString();
      if (content.isEmpty) return;

      final data = jsonDecode(content) as List;
      final migratedData = <Map<String, dynamic>>[];

      for (final plant in data) {
        final plantMap = plant as Map<String, dynamic>;
        if (plantMap.containsKey('wateringFrequency')) {
          migratedData.add(plantMap);
          continue;
        }

        migratedData.add({
          'name': plantMap['name'],
          'wateringFrequency': 1, // Default to once daily
          'wateringSchedule': ['12:00 PM'], // Default schedule
          'imagePath': plantMap['imagePath'],
          'createdAt': plantMap['createdAt'],
        });
      }

      // Save migrated data
      await file.writeAsString(jsonEncode(migratedData));
    } catch (e) {
      await clearAllPlantData();
    }
  }
  static Future<Directory> _safeDocumentsDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } on PlatformException {
      try {
        return await getTemporaryDirectory();
      } catch (_) {
        return Directory.systemTemp;
      }
    }
  }
}
