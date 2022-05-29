import 'package:flutter/material.dart';
import 'package:staysafe_licenta/widgets/progress.dart';
import '../widgets/header.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMap extends StatefulWidget {
  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  @override
  //late GoogleMapController mapController;

  build(context) {
    return Stack(children: [
      GoogleMap(
        initialCameraPosition:
            CameraPosition(target: LatLng(24.150, -110.32), zoom: 10),
        // onMapCreated: _onMapCreated,
        // myLocationEnabled:
        //     true, // Add little blue dot for device location, requires permission from user
        // mapType: MapType.hybrid,
        // trackCameraPosition: true),
      )
    ]);
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   setState(() {
  //     mapController = controller;
  //   });
  // }
}

class LocationMapItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Map Item');
  }
}
