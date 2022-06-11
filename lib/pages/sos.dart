import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:staysafe_licenta/pages/map.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import 'home.dart';
import 'package:location/location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class Sos extends StatefulWidget {
  @override
  _SosState createState() => _SosState();
}

class _SosState extends State<Sos> {
  @override
  void initState() {
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    super.initState();
  }

  Geoflutterfire geo = Geoflutterfire();
  final String? currentUserId = currentUser?.id;
  //Location location = new Location();
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

  addAlertToAlertsFeed(String type) async {
    _updatePosition();
    //Add notification to the Contact Activity feed if you press the Sos button
    QuerySnapshot query =
        await contactsRef.doc(currentUserId).collection('userContacts').get();
    query.docs.forEach((document) async {
      contactsAlertsRef.doc(document.id).collection('alertItems').add({
        "username": currentUser?.username,
        "userId": currentUserId,
        "userProfileImg": currentUser?.photoUrl,
        "latitude": _latitude,
        "longitude": _longitude,
        "timestamp": timestamp,
        "type": type,
      });

      print(document.id);
      print(_longitude);
      print(_latitude);
    });

    if (type == 'sos') {
      GeoFirePoint point =
          geo.point(latitude: _latitude, longitude: _longitude);
      locationsRef.add({'position': point.data, 'name': 'alert'});
      addAlertToActivityFeed(_latitude, _longitude);
    }
  }

  addAlertToActivityFeed(latitude_user, longitude_user) async {
    //_updatePosition();
    //Add notification to the Contact Activity feed if you press the Sos button

    activityFeedRef.add({
      "username": currentUser?.username,
      "userId": currentUserId,
      "userProfileImg": currentUser?.photoUrl,
      "latitude": latitude_user,
      "longitude": longitude_user,
      "timestamp": timestamp,
    });
  }

  // Future<DocumentReference> _addGeoPoint() async {
  //   Position pos = await _determinePosition();
  //   GeoFirePoint point =
  //       geo.point(latitude: pos.latitude, longitude: pos.longitude);
  //   return locationsRef.add({'position': point.data, 'name': 'alert'});
  // }

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
                addAlertToAlertsFeed('sos');

                //_addGeoPoint();
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
            SizedBox(
              height: 100.0,
              width: 150.0,
              child: Divider(
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addAlertToAlertsFeed('notsafe');
              },
              child: Text(
                "I'm not feeling safe",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(25)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                          side: BorderSide(color: Colors.blue)))),
            ),
          ],
        ),
      ),
    );
  }
}
