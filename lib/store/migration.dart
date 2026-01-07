import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// Migration utility to handle data format changes
class DataMigration {
  /// Clear all existing plant data (use this if migration fails)
  static Future<void> clearAllPlantData() async {
    try {
      final dir = await _safeDocumentsDirectory();
      final file = File('${dir.path}/plants.json');
      if (await file.exists()) {
        await file.delete();
        print('Plant data cleared successfully');
      }
    } catch (e) {
      print('Error clearing plant data: $e');
    }
  }

  /// Migrate old plant data to new format
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

        // Check if already migrated
        if (plantMap.containsKey('wateringFrequency')) {
          migratedData.add(plantMap);
          continue;
        }

        // Migrate old format
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
      print('Plant data migrated successfully');
    } catch (e) {
      print('Error migrating plant data: $e');
      // If migration fails, clear the data
      await clearAllPlantData();
    }
  }

  // Falls back to a temporary directory if the platform channel fails.
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
