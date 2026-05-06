import 'package:flutter/material.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

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

class _Category {
  const _Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.tips,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<PlantTip> tips;
}

const List<_Category> _categories = [
  _Category(
    id: 'water',
    label: 'Watering',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF1565C0),
    tips: [
      PlantTip(
        icon: Icons.fingerprint_rounded,
        title: 'Check Soil Moisture',
        description:
            'Stick your finger 1–2 inches into the soil. If it\'s dry, it\'s time to water. Most plants prefer slightly moist, not soggy soil.',
      ),
      PlantTip(
        icon: Icons.water_drop_outlined,
        title: 'Water Thoroughly',
        description:
            'Water slowly until it drains from the bottom. This ensures the entire root system gets hydrated.',
      ),
      PlantTip(
        icon: Icons.wb_twilight_rounded,
        title: 'Morning is Best',
        description:
            'Water in the morning so plants absorb moisture before the heat of the day and to prevent fungal issues.',
      ),
      PlantTip(
        icon: Icons.thermostat_rounded,
        title: 'Room Temperature Water',
        description:
            'Cold water can shock roots. Let tap water sit overnight to reach room temperature and allow chlorine to evaporate.',
      ),
    ],
  ),
  _Category(
    id: 'light',
    label: 'Light',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFF57F17),
    tips: [
      PlantTip(
        icon: Icons.wb_sunny_outlined,
        title: 'Know Your Light Levels',
        description:
            'Bright = near south window. Medium = east/west window. Low = north window. Match plants to their needs.',
      ),
      PlantTip(
        icon: Icons.rotate_right_rounded,
        title: 'Rotate Regularly',
        description:
            'Turn plants a quarter turn every week so all sides get equal light and grow evenly.',
      ),
      PlantTip(
        icon: Icons.lightbulb_outline_rounded,
        title: 'Supplement with Grow Lights',
        description:
            'LED grow lights placed 12–24 inches above plants for 12–16 hours daily can compensate for low natural light.',
      ),
      PlantTip(
        icon: Icons.warning_amber_rounded,
        title: 'Watch for Light Stress',
        description:
            'Brown crispy leaves = too much light. Pale leggy growth = too little. Adjust placement accordingly.',
      ),
    ],
  ),
  _Category(
    id: 'soil',
    label: 'Soil',
    icon: Icons.grass_rounded,
    color: Color(0xFF4E342E),
    tips: [
      PlantTip(
        icon: Icons.science_rounded,
        title: 'Choose the Right Mix',
        description:
            'Most houseplants thrive in well-draining potting mix. Succulents need cactus mix; ferns prefer moisture-retaining soil.',
      ),
      PlantTip(
        icon: Icons.restaurant_rounded,
        title: 'Feed During Growing Season',
        description:
            'Fertilize monthly in spring and summer with diluted liquid fertilizer. Reduce or stop in fall and winter.',
      ),
      PlantTip(
        icon: Icons.refresh_rounded,
        title: 'Refresh Soil Annually',
        description:
            'Repot or refresh the top inch of soil yearly. Old soil loses nutrients and can become compacted.',
      ),
      PlantTip(
        icon: Icons.water_outlined,
        title: 'Ensure Good Drainage',
        description:
            'All pots should have drainage holes. Add perlite or bark to heavy soils to improve drainage.',
      ),
    ],
  ),
  _Category(
    id: 'problems',
    label: 'Problems',
    icon: Icons.bug_report_rounded,
    color: Color(0xFFC62828),
    tips: [
      PlantTip(
        icon: Icons.search_rounded,
        title: 'Inspect Regularly',
        description:
            'Check weekly for pests like spider mites, aphids, or scale. Early detection makes treatment much easier.',
      ),
      PlantTip(
        icon: Icons.healing_rounded,
        title: 'Quarantine New Plants',
        description:
            'Keep new plants separate for 2–3 weeks to ensure they\'re pest-free before introducing them to your collection.',
      ),
      PlantTip(
        icon: Icons.content_cut_rounded,
        title: 'Prune Dead Growth',
        description:
            'Remove yellow, brown, or dead leaves promptly to prevent disease spread and redirect energy to healthy growth.',
      ),
      PlantTip(
        icon: Icons.air_rounded,
        title: 'Improve Air Circulation',
        description:
            'Good airflow prevents fungal issues. Use a small fan or ensure plants aren\'t overcrowded.',
      ),
    ],
  ),
  _Category(
    id: 'seasonal',
    label: 'Seasonal',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFF2E7D32),
    tips: [
      PlantTip(
        icon: Icons.wb_sunny_rounded,
        title: 'Spring: Growth Season',
        description:
            'Increase watering and start fertilizing as plants enter their active growing period. Perfect time for repotting.',
      ),
      PlantTip(
        icon: Icons.local_fire_department_rounded,
        title: 'Summer: Heat Stress',
        description:
            'Move plants away from hot windows, increase humidity, and water more frequently during extreme heat.',
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
    ],
  ),
  _Category(
    id: 'pro',
    label: 'Pro Tips',
    icon: Icons.star_rounded,
    color: Color(0xFF6A1B9A),
    tips: [
      PlantTip(
        icon: Icons.opacity_rounded,
        title: 'Humidity Matters',
        description:
            'Most houseplants prefer 40–60% humidity. Use a humidifier, pebble trays, or group plants together.',
      ),
      PlantTip(
        icon: Icons.psychology_rounded,
        title: 'Learn Your Plants',
        description:
            'Research each plant\'s specific needs. What works for a succulent won\'t work for a fern.',
      ),
      PlantTip(
        icon: Icons.photo_camera_rounded,
        title: 'Document Progress',
        description:
            'Take monthly photos to track growth and spot problems early. It\'s also rewarding to see progress!',
      ),
      PlantTip(
        icon: Icons.favorite_rounded,
        title: 'Start Small',
        description:
            'Begin with easy plants like pothos, snake plants, or ZZ plants before trying challenging species.',
      ),
    ],
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class Tips extends StatefulWidget {
  const Tips({super.key});

  @override
  State<Tips> createState() => _TipsState();
}

class _TipsState extends State<Tips> {
  String _selectedId = _categories.first.id;

  _Category get _selected => _categories.firstWhere((c) => c.id == _selectedId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────
          SliverToBoxAdapter(child: _TipsHeader(theme: theme)),

          // ── Category pills ───────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _PillsDelegate(
              child: _CategoryPills(
                categories: _categories,
                selectedId: _selectedId,
                onSelect: (id) => setState(() => _selectedId = id),
                theme: theme,
              ),
            ),
          ),

          // ── Category title ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _CategoryTitle(category: _selected, theme: theme),
            ),
          ),

          // ── Tips list ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList.builder(
              itemCount: _selected.tips.length,
              itemBuilder: (context, index) => _TipCard(
                tip: _selected.tips[index],
                index: index,
                accentColor: _selected.color,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _TipsHeader extends StatelessWidget {
  const _TipsHeader({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_categories.fold(0, (s, c) => s + c.tips.length)} tips',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Plant Care\nGuide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Expert advice to keep every plant thriving.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category pills ────────────────────────────────────────────────────────────

class _CategoryPills extends StatelessWidget {
  const _CategoryPills({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.theme,
  });

  final List<_Category> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat.id == selectedId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (_) => onSelect(cat.id),
                  avatar: Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : cat.color,
                  ),
                  label: Text(cat.label),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: cat.color,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected
                        ? cat.color
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Sliver delegate to pin the pills row
class _PillsDelegate extends SliverPersistentHeaderDelegate {
  const _PillsDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_PillsDelegate old) => old.child != child;
}

// ── Category title ────────────────────────────────────────────────────────────

class _CategoryTitle extends StatelessWidget {
  const _CategoryTitle({required this.category, required this.theme});

  final _Category category;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${category.tips.length} tips',
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

// ── Tip card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatefulWidget {
  const _TipCard({
    required this.tip,
    required this.index,
    required this.accentColor,
    required this.theme,
  });

  final PlantTip tip;
  final int index;
  final Color accentColor;
  final ThemeData theme;

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expanded
                ? widget.accentColor.withValues(alpha: 0.4)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Number badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icon
                    Icon(widget.tip.icon, size: 18, color: widget.accentColor),
                    const SizedBox(width: 10),
                    // Title
                    Expanded(
                      child: Text(
                        widget.tip.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Expand chevron
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                // Expandable description
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12, left: 4),
                    child: Text(
                      widget.tip.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.55,
                      ),
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
