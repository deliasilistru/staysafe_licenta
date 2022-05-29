import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/header.dart';
import 'home.dart';

class Sos extends StatefulWidget {
  @override
  _SosState createState() => _SosState();
}

class _SosState extends State<Sos> {
  final String? currentUserId = currentUser?.id;

  addAlertToActivityFeed() async {
    //Add notification to the Contact Activity feed if you press the Sos button
    QuerySnapshot query =
        await contactsRef.doc(currentUserId).collection('userContacts').get();
    query.docs.forEach((document) async {
      await FirebaseFirestore.instance
          .collection('alerts')
          .doc(document.id)
          .set({
        "username": currentUser?.username,
        "userId": currentUserId,
        "userProfileImg": currentUser?.photoUrl,
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
