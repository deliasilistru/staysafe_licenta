import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:staysafe_licenta/pages/home.dart';
import 'package:staysafe_licenta/widgets/progress.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  Profile({required this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String? currentUserId = currentUser?.id;
  bool isContact = false;

  @override
  void initState() {
    super.initState();
    checkIfContact();
  }

  checkIfContact() async {
    DocumentSnapshot document = await contactsRef
        .doc(widget.profileId)
        .collection('userContacts')
        .doc(currentUserId)
        .get();
    setState(() {
      isContact = document.exists;
    });
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton(
      {required String text, required VoidCallback function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isContact ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isContact ? Colors.white : Colors.blue,
            border: Border.all(
              color: isContact ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isContact) {
      return buildButton(
          text: "Remove Emergency Contact", function: handleRemoveContact);
    } else if (!isContact) {
      return buildButton(
          text: "Add Emergency Contact", function: handleAddContact);
    }
  }

  handleRemoveContact() {}

  handleAddContact() {
    setState(() {
      isContact = true;
    });
    // Make auth user contact of THAT user (update THEIR contact collection)
    contactsRef
        .doc(widget.profileId)
        .collection('userContacts')
        .doc(currentUserId)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    contactsRef
        .doc(currentUserId)
        .collection('userContacts')
        .doc(widget.profileId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    // activityFeedRef
    //     .document(widget.profileId)
    //     .collection('feedItems')
    //     .document(currentUserId)
    //     .setData({
    //   "type": "follow",
    //   "ownerId": widget.profileId,
    //   "username": currentUser.username,
    //   "userId": currentUserId,
    //   "userProfileImg": currentUser.photoUrl,
    //   "timestamp": timestamp,
    // });
  }

  buildProfileHrader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        String age = user.age;
        String hairColor = user.hairColor;
        String eyeColor = user.eyeColor;
        String height = user.height;
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 60.0,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              buildProfileButton(),
              SizedBox(
                height: 20.0,
                width: 300.0,
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "Age: $age",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "Height: $height",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "Hair Color: $hairColor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "Eye Color: $eyeColor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHrader(),
        ],
      ),
    );
  }
}
