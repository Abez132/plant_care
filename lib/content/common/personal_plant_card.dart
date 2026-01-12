import 'dart:io';
import 'package:flutter/material.dart';

class PersonalPlantCard extends StatelessWidget {
  const PersonalPlantCard({
    super.key,
    required this.name,
    required this.wateringFrequency,
    required this.wateringSchedule,
    required this.imagePath,
    required this.createdAt,
    required this.onDelete,
  });

  final String name;
  final int wateringFrequency;
  final List<String> wateringSchedule;
  final String imagePath;
  final DateTime createdAt;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildImage(theme),
              const SizedBox(width: 16),
              Expanded(child: _buildContent(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plant name and delete button
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                iconSize: 20,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: 'Delete plant',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Watering schedule chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    wateringFrequency == 4
                        ? 'Custom schedule'
                        : '$wateringFrequency time${wateringFrequency > 1 ? 's' : ''} daily',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                wateringSchedule.join(' • '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.8,
                  ),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Date added
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Added ${_formatDate(createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(ThemeData theme) {
    final file = File(imagePath);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: file.existsSync()
            ? Image.file(file, fit: BoxFit.cover)
            : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
