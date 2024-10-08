//updated improvement
import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$lng&key=AIzaSyAsRfbJWJpK_3DfhDTMWL2Tgnf-fu0GI-Q';
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyAsRfbJWJpK_3DfhDTMWL2Tgnf-fu0GI-Q');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
          latitude: latitude, longitude: longitude, address: address);
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location Chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select On Map'),
            ),
          ],
        )
      ],
    );
  }
}

//from chat gpt manage to make the google map appear
// import 'package:favorite_places/models/place.dart';
// import 'package:flutter/material.dart';
// import 'package:location/location.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class LocationInput extends StatefulWidget {
//   const LocationInput({super.key, required this.onSelectLocation});

//   final void Function(PlaceLocation location) onSelectLocation;

//   @override
//   State<LocationInput> createState() => _LocationInputState();
// }

// class _LocationInputState extends State<LocationInput> {
//   PlaceLocation? _pickedLocation;
//   var _isGettingLocation = false;

//   String get locationImage {
//     if (_pickedLocation == null) {
//       return '';
//     }
//     final lat = _pickedLocation!.latitude;
//     final lng = _pickedLocation!.longitude;
//     return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$lng&key=AIzaSyAsRfbJWJpK_3DfhDTMWL2Tgnf-fu0GI-Q';
//   }

//   void _getCurrentLocation() async {
//     try {
//       Location location = Location();

//       bool serviceEnabled = await location.serviceEnabled();
//       if (!serviceEnabled) {
//         serviceEnabled = await location.requestService();
//         if (!serviceEnabled) {
//           return;
//         }
//       }

//       PermissionStatus permissionGranted = await location.hasPermission();
//       if (permissionGranted == PermissionStatus.denied) {
//         permissionGranted = await location.requestPermission();
//         if (permissionGranted != PermissionStatus.granted) {
//           return;
//         }
//       }

//       setState(() {
//         _isGettingLocation = true;
//       });

//       LocationData locationData = await location.getLocation();
//       final lat = locationData.latitude;
//       final lng = locationData.longitude;

//       if (lat == null || lng == null) {
//         return;
//       }

//       final url = Uri.parse(
//           'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyAsRfbJWJpK_3DfhDTMWL2Tgnf-fu0GI-Q');

//       // Log response
//       final response = await http.get(url);
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         try {
//           final resData = json.decode(response.body);
//           if (resData['results'].isEmpty) {
//             throw Exception('No results found');
//           }
//           final address = resData['results'][0]['formatted_address'];

//           setState(() {
//             _pickedLocation = PlaceLocation(
//               latitude: lat,
//               longitude: lng,
//               address: address,
//             );
//             _isGettingLocation = false;
//           });

//           widget.onSelectLocation(_pickedLocation!);
//         } catch (e) {
//           print('Error parsing JSON: $e');
//           setState(() {
//             _isGettingLocation = false;
//           });
//         }
//       } else {
//         print('Error response: ${response.body}');
//         setState(() {
//           _isGettingLocation = false;
//         });
//       }
//     } catch (e) {
//       print('Error: $e');
//       setState(() {
//         _isGettingLocation = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget previewContent = Text(
//       'No Location Chosen',
//       textAlign: TextAlign.center,
//       style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//             color: Theme.of(context).colorScheme.onBackground,
//           ),
//     );

//     if (_pickedLocation != null) {
//       previewContent = Image.network(
//         locationImage,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//       );
//     }

//     if (_isGettingLocation) {
//       previewContent = const CircularProgressIndicator();
//     }

//     return Column(
//       children: [
//         Container(
//           height: 170,
//           width: double.infinity,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             border: Border.all(
//               width: 1,
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//             ),
//           ),
//           child: previewContent,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             TextButton.icon(
//               onPressed: _getCurrentLocation,
//               icon: const Icon(Icons.location_on),
//               label: const Text('Get Current Location'),
//             ),
//             TextButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.map),
//               label: const Text('Select On Map'),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
