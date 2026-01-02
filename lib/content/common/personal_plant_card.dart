import 'dart:io';

import 'package:flutter/material.dart';

class PersonalPlantCard extends StatelessWidget {
  const PersonalPlantCard({
    super.key,
    required this.name,
    required this.watering,
    required this.imagePath,
    required this.createdAt,
  });

  final String name;
  final String watering;
  final String imagePath;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: _buildImage(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(watering, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return Container(
        width: 96,
        height: 96,
        color: Colors.green.shade50,
        alignment: Alignment.center,
        child: const Icon(Icons.local_florist, color: Colors.green),
      );
    }
    return Image.file(file, width: 96, height: 96, fit: BoxFit.cover);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
