import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PlantEntry {
  PlantEntry({
    required this.name,
    required this.watering,
    required this.imagePath,
    required this.createdAt,
  });

  final String name;
  final String watering;
  final String imagePath;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'name': name,
    'watering': watering,
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PlantEntry.fromJson(Map<String, dynamic> json) => PlantEntry(
    name: json['name'] as String,
    watering: json['watering'] as String,
    imagePath: json['imagePath'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

Future<File> savePlantToJson({
  required String name,
  required String watering,
  required File imageFile,
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
    'watering': watering,
    'imagePath': imageFile.path, // store path; you can copy file if needed
    'createdAt': DateTime.now().toIso8601String(),
  });

  // Save back
  return file.writeAsString(jsonEncode(plants));
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
