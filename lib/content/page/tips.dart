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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildTipCategory(
              theme,
              'Watering Wisdom',
              Icons.water_drop_rounded,
              _getWateringTips(),
            ),
            const SizedBox(height: 20),
            _buildTipCategory(
              theme,
              'Light & Location',
              Icons.wb_sunny_rounded,
              _getLightTips(),
            ),
            const SizedBox(height: 20),
            _buildTipCategory(
              theme,
              'Soil & Nutrition',
              Icons.grass_rounded,
              _getSoilTips(),
            ),
            const SizedBox(height: 20),
            _buildTipCategory(
              theme,
              'Common Problems',
              Icons.bug_report_rounded,
              _getProblemTips(),
            ),
            const SizedBox(height: 20),
            _buildTipCategory(
              theme,
              'Seasonal Care',
              Icons.calendar_today_rounded,
              _getSeasonalTips(),
            ),
            const SizedBox(height: 20),
            _buildTipCategory(
              theme,
              'Pro Tips',
              Icons.star_rounded,
              _getProTips(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_florist_rounded,
              size: 32,
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn from the best practices to keep your plants thriving',
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

  Widget _buildTipCategory(
    ThemeData theme,
    String title,
    IconData icon,
    List<PlantTip> tips,
  ) {
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            final isLast = index == tips.length - 1;

            return Column(
              children: [
                _buildTipItem(theme, tip),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      height: 1,
                    ),
                  ),
              ],
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTipItem(ThemeData theme, PlantTip tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              size: 16,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PlantTip> _getWateringTips() {
    return [
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
  }

  List<PlantTip> _getLightTips() {
    return [
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
  }

  List<PlantTip> _getSoilTips() {
    return [
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
            'Replot or refresh the top inch of soil yearly. Old soil loses nutrients and can become compacted, hindering growth.',
      ),
      PlantTip(
        icon: Icons.water_outlined,
        title: 'Ensure Good Drainage',
        description:
            'All pots should have drainage holes. Add perlite or bark to heavy soils to improve drainage and prevent root rot.',
      ),
    ];
  }

  List<PlantTip> _getProblemTips() {
    return [
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
  }

  List<PlantTip> _getSeasonalTips() {
    return [
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
  }

  List<PlantTip> _getProTips() {
    return [
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
  }
}

class PlantTip {
  final IconData icon;
  final String title;
  final String description;

  PlantTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}
