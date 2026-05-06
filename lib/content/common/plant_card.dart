import 'package:flutter/material.dart';
import 'dart:io';

class PlantResultCard extends StatelessWidget {
  const PlantResultCard({
    super.key,
    required this.uploadedImageUrl,
    required this.plantName,
    required this.probability,
    required this.similarImages,
  });

  final String uploadedImageUrl;
  final String plantName;
  final double probability;
  final List<Map<String, dynamic>> similarImages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // ── Hero image as a collapsible app bar ──────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _HeroImage(
                uploadedImageUrl: uploadedImageUrl,
                plantName: plantName,
                probability: probability,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // ── Body content ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Confidence + name chips
                _IdentityRow(plantName: plantName, probability: probability),
                const SizedBox(height: 20),

                // Care tips
                const _CareTipsCard(),
                const SizedBox(height: 20),

                // Similar images
                if (similarImages.isNotEmpty)
                  _SimilarImagesSection(similarImages: similarImages),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero image ────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.uploadedImageUrl,
    required this.plantName,
    required this.probability,
  });

  final String uploadedImageUrl;
  final String plantName;
  final double probability;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(),
        // Gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.35, 1.0],
              colors: [Colors.transparent, Color(0xDD000000)],
            ),
          ),
        ),
        // Name + badge
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plantName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 8),
              _ConfidenceBadge(probability: probability),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (uploadedImageUrl.startsWith('http://') ||
        uploadedImageUrl.startsWith('https://')) {
      return Image.network(
        uploadedImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _Placeholder(),
      );
    }
    return Image.file(
      File(uploadedImageUrl),
      fit: BoxFit.cover,
      errorBuilder: (ctx, e, s) => _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_rounded,
        size: 56,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.probability});
  final double probability;

  Color _badgeColor() {
    if (probability >= 0.8) return const Color(0xFF2E7D32);
    if (probability >= 0.5) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }

  String _badgeLabel() {
    if (probability >= 0.8) return 'High confidence';
    if (probability >= 0.5) return 'Medium confidence';
    return 'Low confidence';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _badgeColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                '${(probability * 100).toStringAsFixed(1)}%  ·  ${_badgeLabel()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Identity row ──────────────────────────────────────────────────────────────

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.plantName, required this.probability});

  final String plantName;
  final double probability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.local_florist_rounded,
            label: 'Identified as',
            value: plantName,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.analytics_rounded,
            label: 'Match score',
            value: '${(probability * 100).toStringAsFixed(1)}%',
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Care tips ─────────────────────────────────────────────────────────────────

class _CareTipsCard extends StatelessWidget {
  const _CareTipsCard();

  static const List<_TipData> _tips = [
    _TipData(
      icon: Icons.wb_sunny_outlined,
      title: 'Light',
      body: 'Bright, indirect light for balanced growth.',
    ),
    _TipData(
      icon: Icons.water_drop_outlined,
      title: 'Water',
      body: 'Water when the top inch of soil feels dry.',
    ),
    _TipData(
      icon: Icons.air_rounded,
      title: 'Humidity',
      body: 'Mist lightly if the air is dry.',
    ),
    _TipData(
      icon: Icons.search_rounded,
      title: 'Health',
      body: 'Check leaves weekly for pests or discoloration.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.eco_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Quick Care Guide',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _tips.map((t) => _TipTile(tip: t, theme: theme)).toList(),
          ),
        ],
      ),
    );
  }
}

class _TipData {
  const _TipData({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _TipTile extends StatelessWidget {
  const _TipTile({required this.tip, required this.theme});
  final _TipData tip;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tip.icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  tip.body,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Similar images ────────────────────────────────────────────────────────────

class _SimilarImagesSection extends StatelessWidget {
  const _SimilarImagesSection({required this.similarImages});

  final List<Map<String, dynamic>> similarImages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: theme.colorScheme.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Similar Plants',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarImages.length,
            itemBuilder: (context, index) {
              final imgUrl = similarImages[index]['url'] as String? ?? '';
              final similarity =
                  similarImages[index]['similarity'] as double? ?? 0.0;
              return Container(
                width: 130,
                margin: EdgeInsets.only(
                  right: index == similarImages.length - 1 ? 0 : 10,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        cacheWidth: 260,
                        errorBuilder: (ctx, e, s) => Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    // Similarity badge
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(similarity * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
