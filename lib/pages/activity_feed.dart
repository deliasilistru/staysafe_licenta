import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staysafe_licenta/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user.dart';
import '../widgets/header_activityfeed.dart';
import '../widgets/progress.dart';
import 'package:location/location.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getAlertsFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> activityFeedItems = [];
    snapshot.docs.forEach((document) {
      activityFeedItems.add(ActivityFeedItem.fromDocument(document));
      // print('Activity Feed Item: ${doc.data}');
    });
    return activityFeedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header_activityfeed(context, titleText: "Activity Feed"),
      body: RefreshIndicator(
        onRefresh: () => getAlertsFeed(),
        child: Container(
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
      ),
    );
  }
}

String alertsItemText = "";

class ActivityFeedItem extends StatelessWidget {
  late final String username;
  late final String userId;
  late final String userProfileImg;
  late final double latitude;
  late final double longitude;
  late final Timestamp timestamp;

  ActivityFeedItem({
    required this.username,
    required this.userId,
    required this.userProfileImg,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      userProfileImg: doc['userProfileImg'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    //configureMediaPreview(context);

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
                      text: ' is in danger! Can you help?',
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(Icons.pin_drop_outlined),
        ),
      ),
    );
  }
}
