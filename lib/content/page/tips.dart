import 'package:flutter/material.dart';

class Tips extends StatelessWidget {
  const Tips({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Plant Care Tips',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SizedBox(height: 16),
          _TipsHeader(theme: theme),
          const SizedBox(height: 24),
          _TipCategory(
            theme: theme,
            title: 'Watering Wisdom',
            icon: Icons.water_drop_rounded,
            tips: _wateringTips,
          ),
          const SizedBox(height: 16),
          _TipCategory(
            theme: theme,
            title: 'Light & Location',
            icon: Icons.wb_sunny_rounded,
            tips: _lightTips,
          ),
          const SizedBox(height: 16),
          _TipCategory(
            theme: theme,
            title: 'Soil & Nutrition',
            icon: Icons.grass_rounded,
            tips: _soilTips,
          ),
          const SizedBox(height: 16),
          _TipCategory(
            theme: theme,
            title: 'Common Problems',
            icon: Icons.bug_report_rounded,
            tips: _problemTips,
          ),
          const SizedBox(height: 16),
          _TipCategory(
            theme: theme,
            title: 'Seasonal Care',
            icon: Icons.calendar_today_rounded,
            tips: _seasonalTips,
          ),
          const SizedBox(height: 16),
          _TipCategory(
            theme: theme,
            title: 'Pro Tips',
            icon: Icons.star_rounded,
            tips: _proTips,
          ),
        ],
      ),
    );
  }
}

// ── Static tip data ───────────────────────────────────────────────────────────

const List<PlantTip> _wateringTips = [
  PlantTip(
    icon: Icons.schedule_rounded,
    title: 'Check Soil Moisture',
    description:
        'Stick your finger 1-2 inches into the soil. If it\'s dry, it\'s time to water. Most plants prefer slightly moist, not soggy soil.',
  ),
  PlantTip(
    icon: Icons.water_drop_outlined,
    title: 'Water Thoroughly',
    description:
        'When watering, do it slowly and thoroughly until water drains from the bottom. This ensures the entire root system gets hydrated.',
  ),
  PlantTip(
    icon: Icons.access_time_rounded,
    title: 'Morning is Best',
    description:
        'Water your plants in the morning so they have time to absorb moisture before the heat of the day and to prevent fungal issues.',
  ),
  PlantTip(
    icon: Icons.thermostat_rounded,
    title: 'Use Room Temperature Water',
    description:
        'Cold water can shock plant roots. Let tap water sit overnight to reach room temperature and allow chlorine to evaporate.',
  ),
];

const List<PlantTip> _lightTips = [
  PlantTip(
    icon: Icons.wb_sunny_outlined,
    title: 'Know Your Light Levels',
    description:
        'Bright light = near south window, Medium = east/west window, Low = north window or away from windows. Match plants to their needs.',
  ),
  PlantTip(
    icon: Icons.rotate_right_rounded,
    title: 'Rotate Regularly',
    description:
        'Turn your plants a quarter turn every week so all sides get equal light exposure and grow evenly.',
  ),
  PlantTip(
    icon: Icons.lightbulb_outline_rounded,
    title: 'Supplement with Grow Lights',
    description:
        'If natural light is limited, LED grow lights can help. Place them 12-24 inches above plants for 12-16 hours daily.',
  ),
  PlantTip(
    icon: Icons.warning_amber_rounded,
    title: 'Watch for Light Stress',
    description:
        'Brown, crispy leaves = too much light. Pale, leggy growth = too little light. Adjust placement accordingly.',
  ),
];

const List<PlantTip> _soilTips = [
  PlantTip(
    icon: Icons.science_rounded,
    title: 'Choose the Right Mix',
    description:
        'Most houseplants thrive in well-draining potting mix. Succulents need cactus mix, while ferns prefer moisture-retaining soil.',
  ),
  PlantTip(
    icon: Icons.restaurant_rounded,
    title: 'Feed During Growing Season',
    description:
        'Fertilize monthly in spring and summer with diluted liquid fertilizer. Reduce or stop feeding in fall and winter.',
  ),
  PlantTip(
    icon: Icons.refresh_rounded,
    title: 'Refresh Soil Annually',
    description:
        'Repot or refresh the top inch of soil yearly. Old soil loses nutrients and can become compacted, hindering growth.',
  ),
  PlantTip(
    icon: Icons.water_outlined,
    title: 'Ensure Good Drainage',
    description:
        'All pots should have drainage holes. Add perlite or bark to heavy soils to improve drainage and prevent root rot.',
  ),
];

const List<PlantTip> _problemTips = [
  PlantTip(
    icon: Icons.bug_report_outlined,
    title: 'Inspect Regularly',
    description:
        'Check your plants weekly for pests like spider mites, aphids, or scale. Early detection makes treatment much easier.',
  ),
  PlantTip(
    icon: Icons.healing_rounded,
    title: 'Quarantine New Plants',
    description:
        'Keep new plants separate for 2-3 weeks to ensure they\'re pest-free before introducing them to your collection.',
  ),
  PlantTip(
    icon: Icons.content_cut_rounded,
    title: 'Prune Dead Growth',
    description:
        'Remove yellow, brown, or dead leaves promptly. This prevents disease spread and redirects energy to healthy growth.',
  ),
  PlantTip(
    icon: Icons.air_rounded,
    title: 'Improve Air Circulation',
    description:
        'Good airflow prevents fungal issues. Use a small fan or ensure plants aren\'t overcrowded to promote healthy air movement.',
  ),
];

const List<PlantTip> _seasonalTips = [
  PlantTip(
    icon: Icons.wb_sunny_rounded,
    title: 'Spring: Growth Season',
    description:
        'Increase watering and start fertilizing as plants enter their active growing period. Perfect time for repotting.',
  ),
  PlantTip(
    icon: Icons.local_fire_department_rounded,
    title: 'Summer: Watch for Heat Stress',
    description:
        'Move plants away from hot windows, increase humidity, and water more frequently. Provide shade during extreme heat.',
  ),
  PlantTip(
    icon: Icons.park_rounded,
    title: 'Fall: Prepare for Dormancy',
    description:
        'Gradually reduce watering and stop fertilizing. Bring outdoor plants inside before temperatures drop below 50°F.',
  ),
  PlantTip(
    icon: Icons.ac_unit_rounded,
    title: 'Winter: Dormancy Care',
    description:
        'Water less frequently, increase humidity near heaters, and provide maximum available light. Avoid cold drafts.',
  ),
];

const List<PlantTip> _proTips = [
  PlantTip(
    icon: Icons.opacity_rounded,
    title: 'Humidity Matters',
    description:
        'Most houseplants prefer 40-60% humidity. Use a humidifier, pebble trays, or group plants together to increase moisture.',
  ),
  PlantTip(
    icon: Icons.psychology_rounded,
    title: 'Learn Your Plants',
    description:
        'Research each plant\'s specific needs. What works for a succulent won\'t work for a fern. Knowledge is the key to success.',
  ),
  PlantTip(
    icon: Icons.photo_camera_rounded,
    title: 'Document Progress',
    description:
        'Take photos of your plants monthly to track growth and spot problems early. It\'s also rewarding to see progress!',
  ),
  PlantTip(
    icon: Icons.favorite_rounded,
    title: 'Start Small',
    description:
        'Begin with easy plants like pothos, snake plants, or ZZ plants. Build confidence and experience before trying challenging species.',
  ),
];

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TipsHeader extends StatelessWidget {
  const _TipsHeader({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_florist_rounded,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expert Plant Care',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best practices to keep your plants thriving',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCategory extends StatelessWidget {
  const _TipCategory({
    required this.theme,
    required this.title,
    required this.icon,
    required this.tips,
  });

  final ThemeData theme;
  final String title;
  final IconData icon;
  final List<PlantTip> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < tips.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
            _TipItem(theme: theme, tip: tips[i]),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.theme, required this.tip});

  final ThemeData theme;
  final PlantTip tip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tip.icon,
              size: 14,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class PlantTip {
  const PlantTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
