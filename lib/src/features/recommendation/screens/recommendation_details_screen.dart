import 'package:flutter/material.dart';
import '../models/venue_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecommendationDetailsScreen extends StatefulWidget {
  final VenueModel venue;

  const RecommendationDetailsScreen({
    Key? key,
    required this.venue,
  }) : super(key: key);

  @override
  State<RecommendationDetailsScreen> createState() =>
      _RecommendationDetailsScreenState();
}

class _RecommendationDetailsScreenState extends State<RecommendationDetailsScreen> {
  late GoogleMapController _mapController;
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildDescription(),
                _buildMap(),
                _buildDetails(),
                _buildReviews(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.venue.photoURL != null
            ? Image.network(
                widget.venue.photoURL!,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.photo,
                  size: 48,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.venue.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                widget.venue.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Text(
                '(${widget.venue.reviewCount} reviews)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.venue.description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.venue.latitude,
            widget.venue.longitude,
          ),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(widget.venue.id),
            position: LatLng(
              widget.venue.latitude,
              widget.venue.longitude,
            ),
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
          setState(() => _isMapReady = true);
        },
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on, 'Address', widget.venue.address),
          _buildDetailRow(
            Icons.access_time,
            'Hours',
            'Open Now • Closes at 10 PM',
          ),
          _buildDetailRow(
            Icons.phone,
            'Phone',
            widget.venue.phone ?? 'Not available',
          ),
          _buildDetailRow(
            Icons.web,
            'Website',
            widget.venue.website ?? 'Not available',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Add review list here
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement directions
                },
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // Implement favorite
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Implement share
              },
            ),
          ],
        ),
      ),
    );
  }
}
