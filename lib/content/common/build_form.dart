import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_care/store/tojson.dart';

class BuildForm extends StatefulWidget {
  const BuildForm({super.key});

  @override
  State<BuildForm> createState() => _BuildFormState();
}

class _BuildFormState extends State<BuildForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wateringController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a plant photo")),
      );
      return;
    }

    // ✅ Collected user data
    final plantName = _nameController.text;
    final watering = _wateringController.text;
    final imageFile = _image;

    // TODO: Save to Firebase / local storage later

    debugPrint("Plant Name: $plantName");
    debugPrint("Watering Schedule: $watering");
    debugPrint("Image Path: ${imageFile!.path}");
    await savePlantToJson(
      name: plantName,
      watering: watering,
      imageFile: imageFile,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Plant saved successfully 🌱")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Plant")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📸 Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: _image == null
                      ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 🌿 Plant name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Plant Name",
                  prefixIcon: Icon(Icons.eco),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter plant name" : null,
              ),

              const SizedBox(height: 16),

              // 💧 Watering schedule
              TextFormField(
                controller: _wateringController,
                decoration: const InputDecoration(
                  labelText: "Watering Schedule",
                  hintText: "e.g. Twice a week",
                  prefixIcon: Icon(Icons.water_drop),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Enter watering schedule"
                    : null,
              ),

              const SizedBox(height: 24),

              // ✅ Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Save Plant"),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
