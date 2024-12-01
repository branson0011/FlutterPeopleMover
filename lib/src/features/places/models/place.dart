import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String id;
  final String name;
  final LatLng location;
  final String? address;
  final double? rating;
  final int? userRatingsTotal;
  final int? currentPopularity;
  final List<PlacePhoto> photos;
  final Map<String, dynamic> rawData;

  Place({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.rating,
    this.userRatingsTotal,
    this.currentPopularity,
    this.photos = const [],
    this.rawData = const {},
  });

  factory Place.fromGooglePlaces(Map<String, dynamic> data) {
    return Place(
      id: data['place_id'],
      name: data['name'],
      location: LatLng(
        data['geometry']['location']['lat'],
        data['geometry']['location']['lng'],
      ),
      address: data['vicinity'],
      rating: data['rating']?.toDouble(),
      userRatingsTotal: data['user_ratings_total'],
      currentPopularity: data['current_popularity'],
      photos: (data['photos'] as List?)
          ?.map((photo) => PlacePhoto.fromGooglePlaces(photo))
          .toList() ?? [],
      rawData: data,
    );
  }
}

class PlacePhoto {
  final String photoReference;
  final int height;
  final int width;

  PlacePhoto({
    required this.photoReference,
    required this.height,
    required this.width,
  });

  factory PlacePhoto.fromGooglePlaces(Map<String, dynamic> data) {
    return PlacePhoto(
      photoReference: data['photo_reference'],
      height: data['height'],
      width: data['width'],
    );
  }

  String getUrl(String apiKey) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$width'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }
}
