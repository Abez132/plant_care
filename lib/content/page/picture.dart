import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:plant_care/content/common/plant_card.dart';
import 'package:plant_care/notifier/value.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['PLANT_ID_KEY'];

Future<String> imageToBase64(XFile picture) async {
  final bytes = await File(picture.path).readAsBytes();
  return base64Encode(bytes);
}

Future<Map<String, dynamic>> identifyPlant(String base64Image) async {
  final url = Uri.parse('https://api.plant.id/v2/identify');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Api-Key':
          apiKey!, // replace with your key
    },
    body: jsonEncode({
      'images': [base64Image],
      'modifiers': ['crops_fast', 'similar_images'],
      'plant_language': 'en',
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Plant identification failed: ${response.body}');
  }
}

class Picture extends StatefulWidget {
  const Picture({super.key});

  @override
  State<Picture> createState() => _PictureState();
}

class _PictureState extends State<Picture> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3C49), Color(0xFF2E8B8B), Color(0xFF9ED9A3)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🌱 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      indexNotifier.value = 0;
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Plant Snapshot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                  Icon(Icons.eco_rounded, color: Colors.white, size: 30),
                ],
              ),

              const SizedBox(height: 22),

              // 📷 Camera Preview Card
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child:
                        cameraController == null ||
                            cameraController?.value.isInitialized == false
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              CameraPreview(cameraController!),

                              // Overlay Hint
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'Align the plant clearly in the frame',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 34,
                    icon: const Icon(Icons.camera_alt_rounded),
                    color: const Color(0xFF0B3C49),
                    onPressed: () async {
                      if (cameraController == null ||
                          cameraController?.value.isInitialized == false) {
                        return;
                      }

                      // Capture image
                      XFile picture = await cameraController!.takePicture();
                      Gal.putImage(picture.path);

                      // Convert to Base64
                      final base64Image = await imageToBase64(picture);

                      // Show loading screen
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B3C49),
                          ),
                        ),
                      );

                      try {
                        // Call Plant.id API
                        final result = await identifyPlant(base64Image);

                        final uploadedImageUrl = result['images'][0]['url'];
                        final suggestion = result['suggestions'][0];
                        final plantName = suggestion['plant_name'];
                        final probability = suggestion['probability'];
                        final similarImages =
                            suggestion['similar_images'] as List;

                        

                        Navigator.pop(context); // hide loading

                        // Show analysis result in a nice UI
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantResultCard(uploadedImageUrl: uploadedImageUrl, plantName: plantName, probability: probability, similarImages: similarImages)
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context); // hide loading
                        print("Error identifying plant: $e");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Failed to identify plant, try again.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> camera = await availableCameras();
    if (camera.isNotEmpty) {
      setState(() {
        cameras = camera;
        cameraController = CameraController(
          camera.first,
          ResolutionPreset.high,
        );
      });

      cameraController
          ?.initialize()
          .then((_) {
            if (!mounted) {
              return;
            }
            setState(() {});
          })
          .catchError((Object e) {
            print(e);
          });
    }
  }
}
