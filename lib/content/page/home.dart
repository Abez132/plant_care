import 'package:flutter/material.dart';
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
  // Keep the list in state so we never recreate the Future unnecessarily
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: theme.colorScheme.primary, size: 26),
            const SizedBox(width: 8),
            Text(
              'Plant Care',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              icon: Icon(
                Icons.person_rounded,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              tooltip: 'Profile',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPlants,
          child: _buildBody(theme),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BuildForm()),
          );
          if (result == true) await _loadPlants();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Plant',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: _loadPlants,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _plants ?? [];
    if (data.isEmpty) return _buildEmptyState(theme);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
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
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      // Wrap in ListView so pull-to-refresh still works on empty state
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_florist_rounded,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Start Your Plant Journey',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add your first plant and we\'ll send you gentle reminders to keep it healthy and thriving.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuildForm()),
                      );
                      if (result == true) await _loadPlants();
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Your First Plant'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
