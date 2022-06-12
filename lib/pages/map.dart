import 'package:flutter/material.dart';
import 'package:staysafe_licenta/pages/home.dart';
import 'package:staysafe_licenta/widgets/progress.dart';
import '../widgets/header.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:google_geocoding/google_geocoding.dart';

class LocationMap extends StatefulWidget {
  late double latitude_contact;
  late double longitude_contact;

  LocationMap(
      {required this.latitude_contact, required this.longitude_contact});
  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers =
      <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
  int _markerIdCounter = 1;

  double _latitude = 0.1;
  double _longitude = 0.1;
  List<GeocodingResult> reverseGeocodingResults = [];

  Future<void> _updatePosition() async {
    Position pos = await _determinePosition();
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
    });
    _animateToUser(widget.latitude_contact, widget.longitude_contact);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _add() async {
    String apiKey = 'AIzaSyAMaQbpp9zQ2cNnvTezTK-Zi1b7OAz6pIk';
    LatLon latlng = LatLon(widget.latitude_contact, widget.longitude_contact);
    GoogleGeocoding googleGeocoding = GoogleGeocoding(apiKey);
    var response = await googleGeocoding.geocoding.getReverse(latlng);

    if (response != null) {
      if (mounted) {
        setState(() {
          reverseGeocodingResults = response.results!;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          reverseGeocodingResults = [];
        });
      }
    }

    String? address = reverseGeocodingResults[0].formattedAddress;
    print(address);

    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(widget.latitude_contact, widget.longitude_contact),
      infoWindow: InfoWindow(title: address, snippet: ''),
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, removeBackButton: false),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(44.4, 44.4),
              zoom: 17.0,
            ),

            myLocationEnabled:
                true, // Add little blue dot for device location, requires permission from user
            mapType: MapType.hybrid,
            markers: markers.values.toSet(),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _updatePosition();
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _animateToUser(latitude_user, longitude_user) async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude_user, longitude_user),
          zoom: 17.0,
        ),
      ),
    );
    print(widget.latitude_contact);
    print(widget.longitude_contact);
    _add();
  }
}

class LocationMapItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Map Item');
  }
}
