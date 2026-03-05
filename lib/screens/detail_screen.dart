import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/listing_description.dart';

class DetailScreen extends StatelessWidget {
  final Listing listing;

  const DetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[300],
                child: const Icon(Icons.business, size: 80, color: Color(0xFF1E293B)),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        listing.category,
                        style: const TextStyle(color: Color(0xFF713F12), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(listing.address, style: const TextStyle(fontSize: 16, color: Colors.black54))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 8),
                    Text(listing.contactNumber, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(listing.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                const SizedBox(height: 32),
                const Text('Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(listing.latitude, listing.longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(listing.id),
                        position: LatLng(listing.latitude, listing.longitude),
                      ),
                    },
                    liteModeEnabled: true, // Improved performance for simple previews
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _launchNavigation(listing.latitude, listing.longitude),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Launch Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
