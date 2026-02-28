import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_description.dart';

final listingRepositoryProvider = Provider((ref) => ListingRepository(FirebaseFirestore.instance));

final listingsStreamProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(listingRepositoryProvider).getListings();
});

class ListingRepository {
  final FirebaseFirestore _firestore;

  ListingRepository(this._firestore);

  CollectionReference get _listings => _firestore.collection('listings');

  Stream<List<Listing>> getListings() {
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Future<void> addListing(Listing listing) async {
    await _listings.add(listing.toMap());
  }

  Future<void> updateListing(Listing listing) async {
    await _listings.doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }

  Stream<List<Listing>> getMyListings(String uid) {
    return _listings
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }
}
