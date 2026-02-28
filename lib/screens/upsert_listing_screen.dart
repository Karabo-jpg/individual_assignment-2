import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_description.dart';
import '../providers/listing_provider.dart';
import '../repositories/auth_repository.dart';

class UpsertListingScreen extends ConsumerStatefulWidget {
  final Listing? listing;

  const UpsertListingScreen({super.key, this.listing});

  @override
  ConsumerState<UpsertListingScreen> createState() => _UpsertListingScreenState();
}

class _UpsertListingScreenState extends ConsumerState<UpsertListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  String? _selectedCategory;

  final List<String> _categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Utility Office',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing?.name);
    _addressController = TextEditingController(text: widget.listing?.address);
    _contactController = TextEditingController(text: widget.listing?.contactNumber);
    _descriptionController = TextEditingController(text: widget.listing?.description);
    _latController = TextEditingController(text: widget.listing?.latitude.toString() ?? '-1.9441');
    _lngController = TextEditingController(text: widget.listing?.longitude.toString() ?? '30.0619');
    _selectedCategory = widget.listing?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final listing = Listing(
        id: widget.listing?.id ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: double.tryParse(_latController.text) ?? -1.9441,
        longitude: double.tryParse(_lngController.text) ?? 30.0619,
        createdBy: user.uid,
        timestamp: DateTime.now(),
      );

      if (widget.listing == null) {
        await ref.read(listingControllerProvider.notifier).addListing(listing);
      } else {
        await ref.read(listingControllerProvider.notifier).updateListing(listing);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(listingControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.listing == null ? 'Add New Listing' : 'Edit Listing',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField('Place Name', _nameController, Icons.business),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category, color: Color(0xFF1E293B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              _buildField('Address', _addressController, Icons.location_on),
              const SizedBox(height: 16),
              _buildField('Contact Number', _contactController, Icons.phone),
              const SizedBox(height: 16),
              _buildField('Description', _descriptionController, Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Latitude', _latController, Icons.map, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Longitude', _lngController, Icons.map, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15),
                  foregroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E293B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }
}
