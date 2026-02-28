import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_description.dart';
import '../repositories/listing_repository.dart';

final listingSearchQueryProvider = StateProvider<String>((ref) => '');
final listingCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final listingsAsync = ref.watch(listingsStreamProvider);
  final searchQuery = ref.watch(listingSearchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(listingCategoryFilterProvider);

  return listingsAsync.whenData((listings) {
    return listings.where((listing) {
      final matchesSearch = listing.name.toLowerCase().contains(searchQuery) ||
          listing.description.toLowerCase().contains(searchQuery);
      final matchesCategory = categoryFilter == null || listing.category == categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  });
});

final listingControllerProvider = StateNotifierProvider<ListingNotifier, AsyncValue<void>>((ref) {
  return ListingNotifier(ref.watch(listingRepositoryProvider));
});

class ListingNotifier extends StateNotifier<AsyncValue<void>> {
  final ListingRepository _repository;

  ListingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addListing(Listing listing) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addListing(listing));
  }

  Future<void> updateListing(Listing listing) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateListing(listing));
  }

  Future<void> deleteListing(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteListing(id));
  }
}
