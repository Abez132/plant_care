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

  String get _frequencyLabel {
    switch (wateringFrequency) {
      case 1:
        return 'Once daily';
      case 2:
        return 'Twice daily';
      case 3:
        return '3× daily';
      default:
        return 'Custom';
    }
  }

  String get _formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image hero ─────────────────────────────────────────
                  _CardHero(
                    imagePath: imagePath,
                    name: name,
                    onDelete: onDelete,
                  ),

                  // ── Info section ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Watering row
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.water_drop_rounded,
                              label: _frequencyLabel,
                              color: theme.colorScheme.primary,
                              background: theme.colorScheme.primaryContainer,
                              foreground: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                wateringSchedule.join('  ·  '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Date row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Added $_formattedDate',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero image with gradient overlay and name ─────────────────────────────────

class _CardHero extends StatelessWidget {
  const _CardHero({
    required this.imagePath,
    required this.name,
    required this.onDelete,
  });

  final String imagePath;
  final String name;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Plant image
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              cacheWidth: 600,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 56,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
            ),

            // Bottom gradient for text legibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),

            // Plant name at bottom-left
            Positioned(
              left: 14,
              right: 56,
              bottom: 14,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Delete button at top-right
            Positioned(
              top: 10,
              right: 10,
              child: _DeleteButton(onDelete: onDelete),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delete button ─────────────────────────────────────────────────────────────

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _confirmDelete(context),
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove plant?'),
        content: const Text(
          'This will also cancel all watering reminders for this plant.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
