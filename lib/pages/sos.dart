import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:staysafe_licenta/pages/map.dart';

import '../models/user.dart';
import '../widgets/header.dart';
import 'home.dart';
import 'package:location/location.dart';

class Sos extends StatefulWidget {
  @override
  _SosState createState() => _SosState();
}

class _SosState extends State<Sos> {
  final String? currentUserId = currentUser?.id;
  Location location = new Location();
  double _latitude = 0.1;
  double _longitude = 0.1;

  Future<void> _updatePosition() async {
    Position pos = await _determinePosition();
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
    });
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

  addAlertToActivityFeed() async {
    _updatePosition();
    //Add notification to the Contact Activity feed if you press the Sos button
    QuerySnapshot query =
        await contactsRef.doc(currentUserId).collection('userContacts').get();
    query.docs.forEach((document) async {
      print(document.id);
      contactsAlertsRef.doc(document.id).collection('alertItems').add({
        "username": currentUser?.username,
        "userId": currentUserId,
        "userProfileImg": currentUser?.photoUrl,
        "latitude": _latitude,
        "longitude": _longitude,
        "timestamp": timestamp,
      });
      print(document.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                addAlertToActivityFeed();
                //print("Sos");
              },
              child: Text(
                'SOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                shape: CircleBorder(),
                padding: EdgeInsets.all(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
