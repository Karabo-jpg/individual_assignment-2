import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/listing_provider.dart';
import '../repositories/listing_repository.dart';
import 'detail_screen.dart';

class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsStreamProvider);

    return Scaffold(
      body: listingsAsync.when(
        data: (listings) {
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-1.9441, 30.0619), // Kigali Center
              zoom: 12,
            ),
            markers: listings.map((listing) => Marker(
              markerId: MarkerId(listing.id),
              position: LatLng(listing.latitude, listing.longitude),
              infoWindow: InfoWindow(
                title: listing.name,
                snippet: listing.category,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DetailScreen(listing: listing)),
                  );
                },
              ),
            )).toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            padding: const EdgeInsets.only(bottom: 20),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
