import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_care/store/tojson.dart';
import 'package:plant_care/notifications/notification_service.dart';

class BuildForm extends StatefulWidget {
  const BuildForm({super.key});

  @override
  State<BuildForm> createState() => _BuildFormState();
}

class _BuildFormState extends State<BuildForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  File? _image;
  int _wateringFrequency = 1; // 1, 2, 3, or 4 (custom) times per day
  final List<TimeOfDay> _customTimes = []; // For custom frequency

  @override
  void initState() {
    super.initState();
    // Remove debug test - no longer needed
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  List<String> _generateWateringSchedule(int frequency) {
    List<String> schedule = [];

    print('🕐 Generating watering schedule for frequency: $frequency');
    print('🕐 Custom times available: $_customTimes');

    switch (frequency) {
      case 1:
        schedule = ['12:00 PM']; // Once at noon
        break;
      case 2:
        schedule = ['8:00 AM', '8:00 PM']; // Morning and evening
        break;
      case 3:
        schedule = [
          '7:00 AM',
          '1:00 PM',
          '7:00 PM',
        ]; // Morning, afternoon, evening
        break;
      case 4: // Custom
        if (_customTimes.isNotEmpty) {
          schedule = _customTimes
              .map((time) => _formatTimeOfDay(time))
              .toList();
          print('🕐 Generated custom schedule: $schedule');
        } else {
          print('❌ No custom times available, using default');
          schedule = ['12:00 PM']; // Fallback
        }
        break;
    }

    print('🕐 Final schedule: $schedule');
    return schedule;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    // Convert 24-hour to 12-hour format properly
    final hour24 = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    String period;
    int hour12;

    if (hour24 == 0) {
      // Midnight: 0:xx -> 12:xx AM
      hour12 = 12;
      period = 'AM';
    } else if (hour24 < 12) {
      // Morning: 1:xx-11:xx -> 1:xx-11:xx AM
      hour12 = hour24;
      period = 'AM';
    } else if (hour24 == 12) {
      // Noon: 12:xx -> 12:xx PM
      hour12 = 12;
      period = 'PM';
    } else {
      // Afternoon/Evening: 13:xx-23:xx -> 1:xx-11:xx PM
      hour12 = hour24 - 12;
      period = 'PM';
    }

    final formatted = '$hour12:$minute $period';
    print(
      '🕐 Formatting time: ${time.hour}:${time.minute} (24h) -> $formatted (12h)',
    );
    return formatted;
  }

  Future<void> _addCustomTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _customTimes.add(picked);
        _customTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  void _removeCustomTime(int index) {
    print('🕐 Removing custom time at index: $index');
    setState(() {
      _customTimes.removeAt(index);
    });
    print('🕐 Custom times after removing: $_customTimes');
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a plant photo")),
      );
      return;
    }

    // Validate custom schedule
    if (_wateringFrequency == 4 && _customTimes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please add at least one watering time for custom schedule",
          ),
        ),
      );
      return;
    }

    // ✅ Collected user data
    final plantName = _nameController.text;
    final wateringSchedule = _generateWateringSchedule(_wateringFrequency);
    final imageFile = _image;
    final plantId = DateTime.now()
        .toIso8601String(); // Use timestamp as unique ID

    // TODO: Save to Firebase / local storage later

    debugPrint("Plant Name: $plantName");
    debugPrint("Watering Frequency: $_wateringFrequency times per day");
    debugPrint("Watering Schedule: $wateringSchedule");
    debugPrint("Image Path: ${imageFile!.path}");

    await savePlantToJson(
      name: plantName,
      wateringFrequency: _wateringFrequency,
      wateringSchedule: wateringSchedule,
      imageFile: imageFile,
      plantId: plantId,
    );

    // Schedule notifications for watering reminders
    await NotificationService.scheduleWateringNotifications(
      plantName: plantName,
      wateringTimes: wateringSchedule,
      plantId: plantId,
    );

    if (!mounted) return;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$plantName saved successfully 🌱\nNotifications scheduled for ${wateringSchedule.join(', ')}",
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back to home
    Navigator.of(context).pop(true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Add Plant",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 Enhanced image picker
              _buildImagePicker(theme),
              const SizedBox(height: 24),

              // 🌿 Enhanced plant name field
              _buildPlantNameField(theme),
              const SizedBox(height: 24),

              // 💧 Enhanced watering frequency selector
              _buildWateringFrequencySelector(theme),
              const SizedBox(height: 32),

              // ✅ Enhanced submit button
              _buildSubmitButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Photo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to add a photo',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose from gallery',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.9,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => setState(() => _image = null),
                            icon: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface,
                            ),
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "e.g., Monstera Deliciosa",
            prefixIcon: Icon(
              Icons.eco_rounded,
              color: theme.colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Enter plant name" : null,
        ),
      ],
    );
  }

  Widget _buildWateringFrequencySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.water_drop_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Watering Schedule',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildFrequencyOption(theme, 1, 'Once a day', '12:00 PM'),
              _buildFrequencyOption(
                theme,
                2,
                'Twice a day',
                '8:00 AM, 8:00 PM',
              ),
              _buildFrequencyOption(
                theme,
                3,
                'Three times a day',
                '7:00 AM, 1:00 PM, 7:00 PM',
              ),
              _buildFrequencyOption(
                theme,
                4,
                'Custom schedule',
                _customTimes.isEmpty
                    ? 'Tap to add custom times'
                    : _customTimes.map((t) => _formatTimeOfDay(t)).join(', '),
              ),

              // Custom time management section
              if (_wateringFrequency == 4) ...[
                const SizedBox(height: 20),
                _buildCustomTimeSection(theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyOption(
    ThemeData theme,
    int value,
    String title,
    String subtitle,
  ) {
    final isSelected = _wateringFrequency == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<int>(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        groupValue: _wateringFrequency,
        onChanged: (newValue) {
          setState(() {
            _wateringFrequency = newValue!;
          });
        },
        activeColor: theme.colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildCustomTimeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Custom Watering Times',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_customTimes.isEmpty)
            Text(
              'No custom times added yet. Tap the button below to add watering times.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Chip(
                  label: Text(
                    _formatTimeOfDay(time),
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  deleteIcon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onDeleted: () => _removeCustomTime(index),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _addCustomTime,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Watering Time'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.check_rounded),
        label: const Text(
          "Save Plant",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: _submitForm,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
