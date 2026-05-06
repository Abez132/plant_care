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

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PlantImage(imagePath: imagePath, theme: theme),
                const SizedBox(width: 16),
                Expanded(
                  child: _PlantContent(
                    name: name,
                    wateringFrequency: wateringFrequency,
                    wateringSchedule: wateringSchedule,
                    createdAt: createdAt,
                    onDelete: onDelete,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantImage extends StatelessWidget {
  const _PlantImage({required this.imagePath, required this.theme});

  final String imagePath;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          cacheWidth: 160, // 2x for high-DPI, avoids decoding full resolution
          errorBuilder: (_, __, ___) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.local_florist_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantContent extends StatelessWidget {
  const _PlantContent({
    required this.name,
    required this.wateringFrequency,
    required this.wateringSchedule,
    required this.createdAt,
    required this.onDelete,
    required this.theme,
  });

  final String name;
  final int wateringFrequency;
  final List<String> wateringSchedule;
  final DateTime createdAt;
  final VoidCallback onDelete;
  final ThemeData theme;

  String get _frequencyLabel {
    if (wateringFrequency == 4) return 'Custom schedule';
    return '$wateringFrequency time${wateringFrequency > 1 ? 's' : ''} daily';
  }

  String get _formattedDate {
    return '${createdAt.year}-'
        '${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            _DeleteButton(onDelete: onDelete, theme: theme),
          ],
        ),
        const SizedBox(height: 12),
        _WateringChip(
          frequencyLabel: _frequencyLabel,
          wateringSchedule: wateringSchedule,
          theme: theme,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Added $_formattedDate',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete, required this.theme});

  final VoidCallback onDelete;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
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
    );
  }
}

class _WateringChip extends StatelessWidget {
  const _WateringChip({
    required this.frequencyLabel,
    required this.wateringSchedule,
    required this.theme,
  });

  final String frequencyLabel;
  final List<String> wateringSchedule;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                frequencyLabel,
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
    );
  }
}
