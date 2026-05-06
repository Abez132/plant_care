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
      if (FirebaseAuth.instance.currentUser == null) _showLoginDialog();
    });
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign in required'),
        content: const Text('You need to be logged in to identify plants.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ── Connectivity ──────────────────────────────────────────────────────────

  Future<bool> _hasInternet() async {
    try {
      final results = await Connectivity().checkConnectivity();
      // checkConnectivity returns List<ConnectivityResult> in newer versions
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (!hasConnection) return false;
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
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
        title: 'No Internet',
        message: 'Please check your connection and try again.',
        icon: Icons.wifi_off_rounded,
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
      if (picked != null && mounted) {
        _showConfirmDialog(File(picked.path));
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showSourceSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SourceSheet(
        theme: theme,
        onCamera: () {
          Navigator.of(ctx).pop();
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.of(ctx).pop();
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  void _showConfirmDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        title: const Text('Use this photo?'),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            imageFile,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Retake'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _image = imageFile);
              _identifyPlant();
            },
            child: const Text('Identify'),
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
        throw Exception('API key not configured');
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
          final s = suggestions[0] as Map<String, dynamic>;
          final rawImgs = s['similar_images'] as List? ?? [];
          final similarImages = rawImgs.map((img) {
            final m = img as Map<String, dynamic>;
            return {
              'url': m['url'] as String? ?? '',
              'similarity': (m['similarity'] ?? 0.0) as double,
            };
          }).toList();

          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlantResultCard(
                uploadedImageUrl: _image!.path,
                plantName: s['plant_name'] as String? ?? 'Unknown Plant',
                probability: (s['probability'] ?? 0.0).toDouble(),
                similarImages: similarImages,
              ),
            ),
          );
        } else {
          _showErrorDialog('No results found. Try a clearer photo.');
        }
      } else {
        _showErrorDialog('Identification failed (${response.statusCode}).');
      }
    } catch (e) {
      _showErrorDialog('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showSimpleDialog({
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.of(ctx).pop(),
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
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // ── Large app bar with gradient ──────────────────────────────
          SliverToBoxAdapter(
            child: _IdentifyHeader(
              hasImage: _image != null,
              onClear: () => setState(() => _image = null),
            ),
          ),

          // ── Auth warning ─────────────────────────────────────────────
          if (user == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _AuthBanner(theme: theme),
              ),
            ),

          // ── Main content ─────────────────────────────────────────────
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _image == null
                  ? _EmptyState(
                      isAuthenticated: user != null,
                      onAddPhoto: _showSourceSheet,
                    )
                  : _ImagePreviewState(
                      image: _image!,
                      isLoading: _isLoading,
                      onNewPhoto: _showSourceSheet,
                      onIdentify: _identifyPlant,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _IdentifyHeader extends StatelessWidget {
  const _IdentifyHeader({required this.hasImage, required this.onClear});

  final bool hasImage;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'AI Powered',
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
                  'Identify\nYour Plant',
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
                  'Snap or upload a photo — we\'ll tell you exactly what it is.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (hasImage)
            IconButton(
              onPressed: onClear,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              tooltip: 'Clear image',
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Auth banner ───────────────────────────────────────────────────────────────

class _AuthBanner extends StatelessWidget {
  const _AuthBanner({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sign in to use plant identification',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAuthenticated, required this.onAddPhoto});

  final bool isAuthenticated;
  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        // Dashed upload zone
        GestureDetector(
          onTap: isAuthenticated ? onAddPhoto : null,
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isAuthenticated
                    ? theme.colorScheme.primary.withValues(alpha: 0.35)
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 2,
                // Dashed effect via strokeAlign
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 40,
                    color: isAuthenticated
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isAuthenticated
                      ? 'Tap to add a photo'
                      : 'Login to get started',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isAuthenticated
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isAuthenticated
                      ? 'Camera or gallery — your choice'
                      : 'Authentication is required',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // How it works row
        Row(
          children: [
            _StepChip(
              number: '1',
              label: 'Pick photo',
              icon: Icons.photo_camera_rounded,
              theme: theme,
            ),
            _StepArrow(theme: theme),
            _StepChip(
              number: '2',
              label: 'AI scans',
              icon: Icons.manage_search_rounded,
              theme: theme,
            ),
            _StepArrow(theme: theme),
            _StepChip(
              number: '3',
              label: 'Get result',
              icon: Icons.eco_rounded,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.number,
    required this.label,
    required this.icon,
    required this.theme,
  });

  final String number;
  final String label;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StepArrow extends StatelessWidget {
  const _StepArrow({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}

// ── Image preview + identify ──────────────────────────────────────────────────

class _ImagePreviewState extends StatelessWidget {
  const _ImagePreviewState({
    required this.image,
    required this.isLoading,
    required this.onNewPhoto,
    required this.onIdentify,
  });

  final File image;
  final bool isLoading;
  final VoidCallback onNewPhoto;
  final VoidCallback onIdentify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),

        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            image,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 16),

        // Loading indicator
        if (isLoading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Analyzing your plant…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNewPhoto,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('New Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onIdentify,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text(
                  'Identify Plant',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

// ── Source bottom sheet ───────────────────────────────────────────────────────

class _SourceSheet extends StatelessWidget {
  const _SourceSheet({
    required this.theme,
    required this.onCamera,
    required this.onGallery,
  });

  final ThemeData theme;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose Photo Source',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            title: 'Camera',
            subtitle: 'Take a new photo',
            color: theme.colorScheme.secondary,
            background: theme.colorScheme.secondaryContainer,
            onTap: onCamera,
          ),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            title: 'Gallery',
            subtitle: 'Choose from your photos',
            color: theme.colorScheme.primary,
            background: theme.colorScheme.primaryContainer,
            onTap: onGallery,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
