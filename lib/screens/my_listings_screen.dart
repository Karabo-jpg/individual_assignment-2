import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_description.dart';
import '../providers/listing_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/listing_repository.dart';
import '../widgets/listing_card.dart';
import 'upsert_listing_screen.dart';
import 'detail_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Center(child: Text('Please log in.'));

    final myListingsAsync = ref.watch(listingsStreamProvider).whenData(
          (listings) => listings.where((l) => l.createdBy == user.uid).toList(),
        );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Listings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const UpsertListingScreen()),
          );
        },
        backgroundColor: const Color(0xFFFACC15),
        child: const Icon(Icons.add, color: Color(0xFF1E293B)),
      ),
      body: myListingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(child: Text('You haven\'t created any listings yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return Stack(
                children: [
                   ListingCard(
                     listing: listing,
                     onTap: () {
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (context) => UpsertListingScreen(listing: listing),
                         ),
                       );
                     },
                   ),
                   Positioned(
                     right: 8,
                     top: 8,
                     child: IconButton(
                       icon: const Icon(Icons.delete, color: Colors.redAccent),
                       onPressed: () {
                          _showDeleteDialog(context, ref, listing.id);
                       },
                     ),
                   ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(listingControllerProvider.notifier).deleteListing(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
