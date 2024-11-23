import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../widgets/place_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExploreSearchBar(
                    isExpanded: _isSearchExpanded,
                    onTap: () {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                    },
                    onClose: () {
                      setState(() {
                        _isSearchExpanded = false;
                      });
                    },
                  ),
                ),
                if (_isSearchExpanded) 
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const SearchResultsList(),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 96,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'filter',
                  onPressed: _showFilterSheet,
                  child: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final position = await locationProvider.getCurrentLocation();
    
    if (position != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }
}

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PlaceCard(
            name: 'Place $index',
            address: '123 Main St',
            rating: 4.5,
            imageUrl: 'https://placeholder.com/300',
            onTap: () {
              // Handle place selection
            },
          ),
        );
      },
    );
  }
}
