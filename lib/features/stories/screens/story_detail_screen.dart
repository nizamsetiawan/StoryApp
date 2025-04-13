import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../controllers/story_controller.dart';
import '../models/story_model.dart';

class StoryDetailScreen extends StatelessWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Story'),
      ),
      body: FutureBuilder<StoryModel>(
        future: controller.getStoryDetail(storyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final story = snapshot.data!;
          final hasLocation = story.lat != null && story.lon != null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Diposting pada ${story.createdAt.day}/${story.createdAt.month}/${story.createdAt.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Text(story.description),
                      if (hasLocation) _buildLocationSection(story),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationSection(StoryModel story) {
    return FutureBuilder<geo.Placemark>(
      future: _getPlacemark(story.lat!, story.lon!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Gagal memuat alamat: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('Alamat tidak tersedia');
        }

        final placemark = snapshot.data!;
        final address = _formatAddress(placemark);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Lokasi:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(address),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(story.lat!, story.lon!),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(story.id),
                    position: LatLng(story.lat!, story.lon!),
                    infoWindow: InfoWindow(
                      title: 'Lokasi Story',
                      snippet: address,
                      onTap: () => _showFullAddress(story.lat!, story.lon!),
                    ),
                  ),
                },
                onTap: (LatLng position) => _showFullAddress(position.latitude, position.longitude),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<geo.Placemark> _getPlacemark(double lat, double lon) async {
    final places = await geo.placemarkFromCoordinates(lat, lon);
    return places.first;
  }

  String _formatAddress(geo.Placemark placemark) {
    return [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
    ].where((part) => part != null && part.isNotEmpty).join(', ');
  }

  Future<void> _showFullAddress(double lat, double lon) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final placemark = await _getPlacemark(lat, lon);
      final address = _formatAddress(placemark);

      Get.back();
      Get.dialog(
        AlertDialog(
          title: const Text('Alamat Lengkap'),
          content: SingleChildScrollView(
            child: Text(address),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', 'Gagal mendapatkan alamat: ${e.toString()}');
    }
  }
}