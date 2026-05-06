import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_care/content/page/login.dart';
import '../common/plant_card.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key});

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        _showLoginDialog();
      }
    });
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Authentication Required'),
        content: const Text(
          'You need to be logged in to use the plant identification feature.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ── Connectivity ──────────────────────────────────────────────────────────

  Future<bool> _hasInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) return false;
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    if (FirebaseAuth.instance.currentUser == null) {
      _showLoginDialog();
      return;
    }
    if (!await _hasInternet()) {
      _showSimpleDialog(
        title: 'No Internet Connection',
        message: 'Please check your internet connection and try again.',
      );
      return;
    }
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (picked != null) _showImageConfirmationDialog(File(picked.path));
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: const Text('Camera'),
                    subtitle: const Text('Take a new photo'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: const Text('Gallery'),
                    subtitle: const Text('Choose from gallery'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageConfirmationDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Is this the image you want to identify?'),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _image = imageFile);
              _identifyPlant();
            },
            child: const Text('Identify Plant'),
          ),
        ],
      ),
    );
  }

  // ── Plant identification ──────────────────────────────────────────────────

  Future<void> _identifyPlant() async {
    if (_image == null) return;
    setState(() => _isLoading = true);

    try {
      final apiKey = dotenv.env['PLANT_ID_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in environment variables');
      }

      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.plant.id/v2/identify'),
        headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
        body: json.encode({
          'images': [base64Image],
          'modifiers': ['similar_images'],
          'plant_details': [
            'common_names',
            'url',
            'description',
            'taxonomy',
            'rank',
            'image',
            'synonyms',
            'edible_parts',
            'watering',
          ],
          'plant_language': 'en',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final suggestions = data['suggestions'] as List?;

        if (suggestions != null && suggestions.isNotEmpty) {
          final suggestion = suggestions[0] as Map<String, dynamic>;
          final rawImages = suggestion['similar_images'] as List? ?? [];
          final similarImages = rawImages
              .map(
                (img) => {
                  'url': img['url'] as String? ?? '',
                  'similarity': (img['similarity'] ?? 0.0) as double,
                },
              )
              .toList();

          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlantResultCard(
                uploadedImageUrl: _image!.path,
                plantName:
                    suggestion['plant_name'] as String? ?? 'Unknown Plant',
                probability: (suggestion['probability'] ?? 0.0).toDouble(),
                similarImages: similarImages,
              ),
            ),
          );
        } else {
          _showErrorDialog(
            'No plant identification results found. Please try with a clearer image.',
          );
        }
      } else {
        _showErrorDialog(
          'Plant identification failed (${response.statusCode}).',
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to identify plant: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showSimpleDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Plant Identification',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        actions: [
          if (_image != null)
            IconButton(
              onPressed: () => setState(() => _image = null),
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Clear Image',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero banner
            _HeroBanner(theme: theme),
            const SizedBox(height: 24),

            // Auth warning
            if (user == null) ...[
              _AuthWarningBanner(theme: theme),
              const SizedBox(height: 16),
            ],

            // Main card
            _ImageCard(
              image: _image,
              isLoading: _isLoading,
              isAuthenticated: user != null,
              onAddPhoto: _showImageSourceDialog,
              onNewPhoto: _showImageSourceDialog,
              onIdentify: _identifyPlant,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.eco_rounded, size: 48, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 12),
          Text(
            'Discover Your Plant',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or add one — we\'ll tell you what it is',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthWarningBanner extends StatelessWidget {
  const _AuthWarningBanner({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authentication Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                Text(
                  'Please log in to use plant identification',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer.withValues(
                      alpha: 0.8,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.image,
    required this.isLoading,
    required this.isAuthenticated,
    required this.onAddPhoto,
    required this.onNewPhoto,
    required this.onIdentify,
    required this.theme,
  });

  final File? image;
  final bool isLoading;
  final bool isAuthenticated;
  final VoidCallback onAddPhoto;
  final VoidCallback onNewPhoto;
  final VoidCallback onIdentify;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: image == null ? _buildEmpty() : _buildWithImage(),
    );
  }

  Widget _buildEmpty() {
    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 44,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Image Selected',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Take a photo or select from gallery\nto identify your plant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: isAuthenticated ? onAddPhoto : null,
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text(
              'Add Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithImage() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            image!,
            height: 280,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Analyzing your plant…',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNewPhoto,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('New Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: isLoading ? null : onIdentify,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Identify'),
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
      ],
    );
  }
}
