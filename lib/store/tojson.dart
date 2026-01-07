import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PlantEntry {
  PlantEntry({
    required this.name,
    required this.wateringFrequency,
    required this.wateringSchedule,
    required this.imagePath,
    required this.createdAt,
    this.plantId,
  });

  final String name;
  final int wateringFrequency;
  final List<String> wateringSchedule;
  final String imagePath;
  final DateTime createdAt;
  final String? plantId; // For notification management

  Map<String, dynamic> toJson() => {
    'name': name,
    'wateringFrequency': wateringFrequency,
    'wateringSchedule': wateringSchedule,
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
    'plantId': plantId,
  };

  factory PlantEntry.fromJson(Map<String, dynamic> json) => PlantEntry(
    name: json['name'] as String,
    wateringFrequency:
        json['wateringFrequency'] as int? ??
        1, // Default to once daily for old entries
    wateringSchedule: json['wateringSchedule'] != null
        ? List<String>.from(json['wateringSchedule'] as List)
        : ['12:00 PM'], // Default schedule for old entries
    imagePath: json['imagePath'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    plantId: json['plantId'] as String?,
  );
}

Future<File> savePlantToJson({
  required String name,
  required int wateringFrequency,
  required List<String> wateringSchedule,
  required File imageFile,
  String? plantId,
}) async {
  final dir = await _safeDocumentsDirectory();
  final file = File('${dir.path}/plants.json');

  // Load existing list or start new
  List<dynamic> plants = [];
  if (await file.exists()) {
    final existing = await file.readAsString();
    if (existing.isNotEmpty) plants = jsonDecode(existing);
  }

  // Append new entry
  plants.add({
    'name': name,
    'wateringFrequency': wateringFrequency,
    'wateringSchedule': wateringSchedule,
    'imagePath': imageFile.path, // store path; you can copy file if needed
    'createdAt': DateTime.now().toIso8601String(),
    'plantId': plantId,
  });

  // Save back
  return file.writeAsString(jsonEncode(plants));
}

Future<void> deletePlantByCreatedAt(String createdAtIso) async {
  final dir = await _safeDocumentsDirectory();
  final file = File('${dir.path}/plants.json');
  if (!await file.exists()) return;
  final content = await file.readAsString();
  if (content.isEmpty) return;
  final data = jsonDecode(content) as List;
  data.removeWhere((e) => e['createdAt'] == createdAtIso);
  await file.writeAsString(jsonEncode(data));
}

Future<List<PlantEntry>> loadPlantsFromJson() async {
  final dir = await _safeDocumentsDirectory();
  final file = File('${dir.path}/plants.json');
  if (!await file.exists()) return [];
  final content = await file.readAsString();
  if (content.isEmpty) return [];
  final data = jsonDecode(content) as List;
  return data
      .map((e) => PlantEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

// Falls back to a temporary directory if the platform channel fails.
Future<Directory> _safeDocumentsDirectory() async {
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
