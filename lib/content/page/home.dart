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
  late Future<List<PlantEntry>> _plants;

  @override
  void initState() {
    super.initState();
    _plants = _initializeData();
  }

  Future<List<PlantEntry>> _initializeData() async {
    // Run migration first
    await DataMigration.migratePlantData();
    // Then load plants
    return await loadPlantsFromJson();
  }

  Future<void> _refreshPlants() async {
    final loaded = await loadPlantsFromJson();
    if (!mounted) return;
    setState(() {
      _plants = Future.value(loaded);
    });
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
            Icon(Icons.eco, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Plant Care',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              tooltip: 'Profile',
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPlants,
          child: FutureBuilder<List<PlantEntry>>(
            future: _plants,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return _buildEmptyState(theme);
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final plant = data[index];
                  return PersonalPlantCard(
                    name: plant.name,
                    wateringFrequency: plant.wateringFrequency,
                    wateringSchedule: plant.wateringSchedule,
                    imagePath: plant.imagePath,
                    createdAt: plant.createdAt,
                    onDelete: () async {
                      // Cancel notifications for this plant
                      if (plant.plantId != null) {
                        await NotificationService.cancelPlantNotifications(
                          plant.plantId!,
                        );
                      }

                      await deletePlantByCreatedAt(
                        plant.createdAt.toIso8601String(),
                      );
                      await _refreshPlants();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuildForm()),
          );
          if (result == true) {
            await _refreshPlants();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Plant',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 6,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Beautiful plant illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_florist,
                size: 64,
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
            const SizedBox(height: 16),

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
                  MaterialPageRoute(builder: (context) => const BuildForm()),
                );
                if (result == true) {
                  await _refreshPlants();
                }
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
    );
  }
}
