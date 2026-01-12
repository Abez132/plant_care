import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_care/content/page/home.dart';
import 'package:plant_care/content/page/login.dart';
import 'package:plant_care/notifier/value.dart';
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
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginDialog();
      });
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text(
            'You need to be logged in to use the plant identification feature.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check by making a simple HTTP request
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Please check your internet connection and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginDialog();
      return;
    }

    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      _showNoInternetDialog();
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        _showImageConfirmationDialog(imageFile);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showImageConfirmationDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Is this the image you want to identify?'),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _image = imageFile;
                });
                _identifyPlant();
              },
              child: const Text('Identify Plant'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _identifyPlant() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create request for Plant.id API v2
      final uri = Uri.parse('https://api.plant.id/v2/identify');

      // Read image as base64
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Get API key from environment variables
      final apiKey = dotenv.env['PLANT_ID_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in environment variables');
      }

      // Prepare request body for Plant.id API v2
      final requestBody = {
        'images': [base64Image],
        'modifiers': ['similar_images'],
        'plant_details': [
          'common_names',
          'url',
          'description',
          'taxonomy',
          'rank',
          'gbif_id',
          'inaturalist_id',
          'image',
          'synonyms',
          'edible_parts',
          'watering',
        ],
        'plant_language': 'en',
      };

      // Send POST request
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['suggestions'] != null && data['suggestions'].isNotEmpty) {
          final suggestion = data['suggestions'][0];

          // Extract similar images
          List<Map<String, dynamic>> similarImages = [];
          if (suggestion['similar_images'] != null) {
            similarImages = List<Map<String, dynamic>>.from(
              suggestion['similar_images'].map(
                (img) => {
                  'url': img['url'],
                  'similarity': img['similarity'] ?? 0.0,
                },
              ),
            );
          }

          // Navigate to PlantResultCard with API results
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlantResultCard(
                uploadedImageUrl: _image!.path,
                plantName: suggestion['plant_name'] ?? 'Unknown Plant',
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
          'Plant identification failed. Status: ${response.statusCode}\nResponse: ${response.body}',
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to identify plant: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identification'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            indexNotifier.value = 0;

            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (context) => const Home()),
            // );
          },
          tooltip: 'Back to Home',
        ),
        actions: [
          if (_image != null)
            IconButton(
              onPressed: _clearImage,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Image',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user == null)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please log in to use plant identification',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_image == null) ...[
                      Icon(Icons.camera_alt, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Take a photo or select from gallery to identify your plant',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: user != null ? _showImageSourceDialog : null,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ] else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Identifying plant...'),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.refresh),
                            label: const Text('New Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (!_isLoading)
                            ElevatedButton.icon(
                              onPressed: _identifyPlant,
                              icon: const Icon(Icons.search),
                              label: const Text('Identify'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Better Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Take clear, well-lit photos'),
                    const Text(
                      '• Include leaves, flowers, or distinctive features',
                    ),
                    const Text('• Avoid blurry or dark images'),
                    const Text('• Get close to the plant for detail'),
                    const Text('• Ensure good lighting conditions'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
