import 'package:flutter/material.dart';
import 'package:plant_care/content/common/build_form.dart';
import 'package:plant_care/content/common/personal_plant_card.dart';
import 'package:plant_care/store/tojson.dart';

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
    _plants = loadPlantsFromJson();
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
      appBar: AppBar(title: const Text('Plant Care'), centerTitle: true),
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
                    watering: plant.watering,
                    imagePath: plant.imagePath,
                    createdAt: plant.createdAt,
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuildForm()),
          );
          await _refreshPlants();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add plant'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 72, color: Colors.green.shade600),
            const SizedBox(height: 16),
            Text(
              'Start your plant journey',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first plant and we\'ll remind you when to care for it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuildForm()),
                );
                await _refreshPlants();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add plant'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
