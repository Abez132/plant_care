import 'package:flutter/material.dart';

class PlantResultCard extends StatelessWidget {
  final String uploadedImageUrl;
  final String plantName;
  final double probability;
  final List similarImages;
  final dynamic watering;
  final dynamic sunlight;

  const PlantResultCard({
    super.key,
    required this.uploadedImageUrl,
    required this.plantName,
    required this.probability,
    required this.similarImages,
    required this.watering,
    required this.sunlight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                              appBar: AppBar(title: const Text("Plant Result")),
                              body: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Uploaded Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        uploadedImageUrl,
                                        height: 250,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Plant Name & Confidence
                                    Text(
                                      plantName,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Confidence: ${(probability * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Tips (Watering / Sunlight)
                                    Card(
                                      color: const Color(0xFFE8F5E9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Care Tips',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[900],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Watering: $watering',
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'Sunlight: $sunlight',
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Similar Images
                                    if (similarImages.isNotEmpty) ...[
                                      const Text(
                                        'Similar Images',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: similarImages.length,
                                          itemBuilder: (context, index) {
                                            final imgUrl =
                                                similarImages[index]['url'];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  imgUrl,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
  }
}
