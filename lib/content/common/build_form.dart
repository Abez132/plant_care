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
  final _nameController = TextEditingController();

  File? _image;
  int _wateringFrequency = 1;
  final List<TimeOfDay> _customTimes = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Image ─────────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  // ── Schedule helpers ──────────────────────────────────────────────────────

  List<String> _generateSchedule(int frequency) {
    switch (frequency) {
      case 1:
        return ['12:00 PM'];
      case 2:
        return ['8:00 AM', '8:00 PM'];
      case 3:
        return ['7:00 AM', '1:00 PM', '7:00 PM'];
      default:
        return _customTimes.isNotEmpty
            ? _customTimes.map(_formatTime).toList()
            : ['12:00 PM'];
    }
  }

  String _formatTime(TimeOfDay t) {
    final h24 = t.hour;
    final min = t.minute.toString().padLeft(2, '0');
    if (h24 == 0) return '12:$min AM';
    if (h24 < 12) return '$h24:$min AM';
    if (h24 == 12) return '12:$min PM';
    return '${h24 - 12}:$min PM';
  }

  Future<void> _addCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _customTimes.add(picked);
        _customTimes.sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
      });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      _showSnack('Please select a plant photo');
      return;
    }
    if (_wateringFrequency == 4 && _customTimes.isEmpty) {
      _showSnack('Please add at least one custom watering time');
      return;
    }

    final name = _nameController.text.trim();
    final schedule = _generateSchedule(_wateringFrequency);
    final plantId = DateTime.now().toIso8601String();

    await savePlantToJson(
      name: name,
      wateringFrequency: _wateringFrequency,
      wateringSchedule: schedule,
      imageFile: _image!,
      plantId: plantId,
    );

    await NotificationService.scheduleWateringNotifications(
      plantName: name,
      wateringTimes: schedule,
      plantId: plantId,
    );

    if (!mounted) return;
    _showSnack('$name saved 🌱  ·  Reminders set for ${schedule.join(', ')}');
    Navigator.of(context).pop(true);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Add Plant',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _SectionLabel(label: 'Plant Photo', icon: Icons.camera_alt_rounded),
            const SizedBox(height: 10),
            _ImagePicker(
              image: _image,
              onTap: _pickImage,
              onClear: () => setState(() => _image = null),
            ),

            const SizedBox(height: 28),
            _SectionLabel(label: 'Plant Name', icon: Icons.eco_rounded),
            const SizedBox(height: 10),
            _NameField(controller: _nameController),

            const SizedBox(height: 28),
            _SectionLabel(
              label: 'Watering Schedule',
              icon: Icons.water_drop_rounded,
            ),
            const SizedBox(height: 10),
            _ScheduleSelector(
              selected: _wateringFrequency,
              customTimes: _customTimes,
              onSelect: (v) => setState(() => _wateringFrequency = v),
              onAddTime: _addCustomTime,
              onRemoveTime: (i) => setState(() => _customTimes.removeAt(i)),
              formatTime: _formatTime,
            ),

            const SizedBox(height: 36),
            _SubmitButton(onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ── Image picker ──────────────────────────────────────────────────────────────

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.image,
    required this.onTap,
    required this.onClear,
  });

  final File? image;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: image != null
                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: image != null ? 2 : 1.5,
          ),
        ),
        child: image == null ? _emptyState(theme) : _imagePreview(theme),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_a_photo_rounded,
            size: 30,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap to add a photo',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose from gallery',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _imagePreview(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(image!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Name field ────────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: 'e.g. Monstera, Cactus…',
        prefixIcon: Icon(
          Icons.local_florist_rounded,
          color: theme.colorScheme.primary,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter a plant name' : null,
    );
  }
}

// ── Schedule selector ─────────────────────────────────────────────────────────

class _ScheduleSelector extends StatelessWidget {
  const _ScheduleSelector({
    required this.selected,
    required this.customTimes,
    required this.onSelect,
    required this.onAddTime,
    required this.onRemoveTime,
    required this.formatTime,
  });

  final int selected;
  final List<TimeOfDay> customTimes;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddTime;
  final ValueChanged<int> onRemoveTime;
  final String Function(TimeOfDay) formatTime;

  static const _options = [
    (value: 1, title: 'Once a day', subtitle: '12:00 PM'),
    (value: 2, title: 'Twice a day', subtitle: '8:00 AM  ·  8:00 PM'),
    (
      value: 3,
      title: 'Three times a day',
      subtitle: '7:00 AM  ·  1:00 PM  ·  7:00 PM',
    ),
    (value: 4, title: 'Custom schedule', subtitle: 'Set your own times'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _options.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                _ScheduleOption(
                  title: _options[i].title,
                  subtitle: _options[i].value == 4 && customTimes.isNotEmpty
                      ? customTimes.map(formatTime).join('  ·  ')
                      : _options[i].subtitle,
                  value: _options[i].value,
                  selected: selected,
                  onTap: () => onSelect(_options[i].value),
                ),
              ],
            ],
          ),
        ),

        // Custom time section
        if (selected == 4) ...[
          const SizedBox(height: 12),
          _CustomTimeSection(
            times: customTimes,
            onAdd: onAddTime,
            onRemove: onRemoveTime,
            formatTime: formatTime,
          ),
        ],
      ],
    );
  }
}

class _ScheduleOption extends StatelessWidget {
  const _ScheduleOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int value;
  final int selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selected == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Custom radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}

class _CustomTimeSection extends StatelessWidget {
  const _CustomTimeSection({
    required this.times,
    required this.onAdd,
    required this.onRemove,
    required this.formatTime,
  });

  final List<TimeOfDay> times;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final String Function(TimeOfDay) formatTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
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
                Icons.schedule_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Custom Times',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (times.isEmpty)
            Text(
              'No times added yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: times.asMap().entries.map((e) {
                return Chip(
                  label: Text(
                    formatTime(e.value),
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  deleteIcon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onDeleted: () => onRemove(e.key),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Time'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                ),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submit button ─────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded),
        label: const Text(
          'Save Plant',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
