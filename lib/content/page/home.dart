import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_care/content/common/build_form.dart';
import 'package:plant_care/content/common/personal_plant_card.dart';
import 'package:plant_care/content/page/login.dart';
import 'package:plant_care/store/tojson.dart';
import 'package:plant_care/store/migration.dart';
import 'package:plant_care/notifications/notification_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<PlantEntry>? _plants;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await DataMigration.migratePlantData();
      final loaded = await loadPlantsFromJson();
      if (!mounted) return;
      setState(() {
        _plants = loaded;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _deletePlant(PlantEntry plant) async {
    if (plant.plantId != null) {
      await NotificationService.cancelPlantNotifications(plant.plantId!);
    }
    await deletePlantByCreatedAt(plant.createdAt.toIso8601String());
    await _loadPlants();
  }

  Future<void> _openAddPlant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuildForm()),
    );
    if (result == true) await _loadPlants();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPlants,
          color: theme.colorScheme.primary,
          child: _buildBody(theme),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPlant,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Plant',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorState(onRetry: _loadPlants);
    }

    final data = _plants ?? [];

    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _HomeHeader(
            plantCount: data.length,
            onProfileTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ),

        if (data.isEmpty)
          // ── Empty state ────────────────────────────────────────────────
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(onAddPlant: _openAddPlant),
          )
        else ...[
          // ── Section label ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Your Plants',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // ── Plant list ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            sliver: SliverList.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final plant = data[index];
                return PersonalPlantCard(
                  key: ValueKey(plant.createdAt.toIso8601String()),
                  name: plant.name,
                  wateringFrequency: plant.wateringFrequency,
                  wateringSchedule: plant.wateringSchedule,
                  imagePath: plant.imagePath,
                  createdAt: plant.createdAt,
                  onDelete: () => _deletePlant(plant),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.plantCount, required this.onProfileTap});

  final int plantCount;
  final VoidCallback onProfileTap;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String? get _userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final name = user.displayName;
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: greeting + avatar ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting${name != null ? ', $name' : ''}! 👋',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plant Care',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AvatarButton(onTap: onProfileTap),
            ],
          ),

          const SizedBox(height: 20),

          // ── Stats banner ─────────────────────────────────────────────
          _StatsBanner(plantCount: plantCount),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          color: theme.colorScheme.primaryContainer,
        ),
        child: ClipOval(
          child: photoUrl != null
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultIcon(theme),
                )
              : _defaultIcon(theme),
        ),
      ),
    );
  }

  Widget _defaultIcon(ThemeData theme) => Icon(
    Icons.person_rounded,
    color: theme.colorScheme.onPrimaryContainer,
    size: 26,
  );
}

class _StatsBanner extends StatelessWidget {
  const _StatsBanner({required this.plantCount});
  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.local_florist_rounded,
              value: '$plantCount',
              label: plantCount == 1 ? 'Plant' : 'Plants',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_active_rounded,
              value: plantCount > 0 ? 'Active' : 'None',
              label: 'Reminders',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.water_drop_rounded,
              value: plantCount > 0 ? 'On' : 'Off',
              label: 'Schedule',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPlant});
  final VoidCallback onAddPlant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_florist_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'No plants yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add your first plant and we\'ll send you gentle reminders to keep it healthy.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onAddPlant,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Plant'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
