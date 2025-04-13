import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../../../utils/constraints/colors.dart';
import '../../../utils/helpers/loaders.dart';
import '../controllers/story_controller.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _location = loc.Location();
  final _picker = ImagePicker();
  File? _imageFile;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        if (fileSize > 1 * 1024 * 1024) {
          TLoaders.errorSnackBar(title: 'Error', message: 'Image size should be less than 1MB');
          return;
        }

        setState(() => _imageFile = file);
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick image');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final permission = await _location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        await _location.requestPermission();
      }

      if (permission != loc.PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }

      final locationData = await _location.getLocation();
      setState(() {
        _selectedLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
      await _getAddressFromLatLng(_selectedLocation!);

      TLoaders.successSnackBar(
          title: 'Success',
          message: 'Location obtained successfully'
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to get location: ${e.toString()}');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      final places = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (places.isNotEmpty) {
        final address = '${places[0].street}, ${places[0].locality}';
        _addressController.text = address;
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to get address: ${e.toString()}');
    }
  }

  Future<void> _submitStory() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Please select an image');
        return;
      }

      try {
        final controller = Get.find<StoryController>();
        await controller.addStory(
          description: _descriptionController.text,
          photoFile: _imageFile!,
          lat: _selectedLocation?.latitude,
          lon: _selectedLocation?.longitude,
        );
        Get.back();
      } catch (e) {
        TLoaders.errorSnackBar(title: 'Error', message: 'Failed to add story');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Story'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Preview
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _imageFile == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48),
                        SizedBox(height: 8),
                        Text('Tap to add photo'),
                      ],
                    ),
                  )
                      : Stack(
                    children: [
                      Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: FloatingActionButton.small(
                          onPressed: _showImageSourceDialog,
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Tell your story...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 10) {
                    return 'Description should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Section
              const Text('Select Location:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-6.2088, 106.8456),
                    zoom: 12,
                  ),
                  onTap: (latLng) {
                    setState(() => _selectedLocation = latLng);
                    _getAddressFromLatLng(latLng);
                  },
                  markers: _selectedLocation != null
                      ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    ),
                  }
                      : {},
                ),
              ),
              const SizedBox(height: 8),

              // Location Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current Location'),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Address Display
              TextFormField(
                controller: _addressController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Location Address',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isLoadingLocation
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: TColors.primary,),
                  )
                      : const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Image Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitStory,
                  child: const Text('Submit Story'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _pickImage(ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}