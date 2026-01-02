import 'dart:io';
import 'package:flutter/material.dart';

class PersonalPlantCard extends StatelessWidget {
  const PersonalPlantCard({
    super.key,
    required this.name,
    required this.watering,
    required this.imagePath,
    required this.createdAt,
    required this.onDelete,
  });

  final String name;
  final String watering;
  final String imagePath;
  final DateTime createdAt;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.green.shade50.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌱 Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        splashRadius: 20,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 💧 Watering chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          size: 16,
                          color: Colors.blue.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          watering,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 📅 Date
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📸 Image with subtle overlay
  Widget _buildImage() {
    final file = File(imagePath);

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(20),
      ),
      child: Stack(
        children: [
          file.existsSync()
              ? Image.file(
                  file,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 120,
                  height: 120,
                  color: Colors.green.shade100,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.local_florist_rounded,
                    size: 40,
                    color: Colors.green.shade600,
                  ),
                ),

          // Soft gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
