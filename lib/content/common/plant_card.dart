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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Plant Result',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(
              uploadedImageUrl: uploadedImageUrl,
              plantName: plantName,
              probability: probability,
            ),
            const SizedBox(height: 20),
            _MetricsRow(plantName: plantName, probability: probability),
            const SizedBox(height: 16),
            const _CareTipsCard(),
            if (similarImages.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SimilarImagesSection(similarImages: similarImages),
            ],
          ],
        ),
      ),
    );
  }
}

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 280,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color.fromARGB(180, 0, 0, 0)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(probability * 100).toStringAsFixed(1)}% confidence',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (uploadedImageUrl.startsWith('http://') ||
        uploadedImageUrl.startsWith('https://')) {
      return Image.network(
        uploadedImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _BrokenImagePlaceholder(),
      );
    }
    return Image.file(
      File(uploadedImageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _BrokenImagePlaceholder(),
    );
  }
}

class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_rounded,
        size: 50,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.plantName, required this.probability});

  final String plantName;
  final double probability;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetricCard(
          icon: Icons.grass_rounded,
          label: 'Common name',
          value: plantName,
        ),
        const SizedBox(width: 12),
        _MetricCard(
          icon: Icons.shield_rounded,
          label: 'Confidence',
          value: '${(probability * 100).toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CareTipsCard extends StatelessWidget {
  const _CareTipsCard();

  static const List<String> _tips = [
    'Give bright, indirect light for balanced growth.',
    'Water when the top inch of soil feels dry.',
    'Mist lightly to boost humidity if air is dry.',
    'Check leaves weekly for pests or discoloration.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Care Tips',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
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
}

class _SimilarImagesSection extends StatelessWidget {
  const _SimilarImagesSection({required this.similarImages});

  final List<Map<String, dynamic>> similarImages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Images',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarImages.length,
            itemBuilder: (context, index) {
              final imgUrl = similarImages[index]['url'] as String? ?? '';
              return Container(
                margin: EdgeInsets.only(
                  right: index == similarImages.length - 1 ? 0 : 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    imgUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    cacheWidth: 240,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
