import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staysafe_licenta/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class Alerts extends StatefulWidget {
  @override
  _AlertsState createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  getAlertsFeed() async {
    QuerySnapshot snapshot = await contactsAlertsRef
        .doc(currentUser?.id)
        .collection('alertItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<AlertsItem> alertsItems = [];
    snapshot.docs.forEach((document) {
      alertsItems.add(AlertsItem.fromDocument(document));
      // print('Activity Feed Item: ${doc.data}');
    });
    return alertsItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, titleText: "Contact's Alerts"),
      body: Container(
          child: FutureBuilder(
        future: getAlertsFeed(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: snapshot.data,
          );
        },
      )),
    );
  }
}

String alertsItemText = "";

class AlertsItem extends StatelessWidget {
  late final String username;
  late final String userId;
  late final String userProfileImg;
  late final double latitude;
  late final double longitude;
  late final Timestamp timestamp;
  late final String type;

  AlertsItem({
    required this.username,
    required this.userId,
    required this.userProfileImg,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.type,
  });

  factory AlertsItem.fromDocument(DocumentSnapshot doc) {
    return AlertsItem(
      username: doc['username'],
      userId: doc['userId'],
      userProfileImg: doc['userProfileImg'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      timestamp: doc['timestamp'],
      type: doc['type'],
    );
  }

  void configureMediaPreview(context) {
    if (type == 'sos') {
      alertsItemText = "is in danger! Tap to see the location of the alert";
    } else if (type == 'notsafe') {
      alertsItemText = "is not feeling safe!";
    } else {
      alertsItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showMap(context,
                latitude_user: latitude, longitude_user: longitude),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $alertsItemText',
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            DateFormat('yyyy-MM-dd  kk:mm:ss').format(timestamp.toDate()),
            //timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(Icons.pin_drop),
        ),
      ),
    );
  }
}
