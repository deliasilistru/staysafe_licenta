import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import '../models/user.dart';
import '../widgets/progress.dart';
import 'home.dart';

class EditProfile extends StatefulWidget {
  final String? currentUserId;

  EditProfile({required this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController hairController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController eyesController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  bool isLoading = false;
  User? user;
  bool _displayNameValid = true;
  bool _hairValid = true;
  bool _ageValid = true;
  bool _eyesValid = true;
  bool _heightValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);

    String? name = user?.displayName;
    String? hair = user?.hairColor;
    String? eyes = user?.eyeColor;
    String? age = user?.age;
    String? height = user?.height;

    displayNameController.text = name!;
    hairController.text = hair!;
    eyesController.text = eyes!;
    ageController.text = age!;
    heightController.text = height!;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Age",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: ageController,
          decoration: InputDecoration(
            hintText: "Update Age",
            errorText: _ageValid ? null : "Age too long",
          ),
        )
      ],
    );
  }

  Column buildHairField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Hair Color",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: hairController,
          decoration: InputDecoration(
            hintText: "Update Hair Color",
            errorText: _hairValid ? null : "Input too long",
          ),
        )
      ],
    );
  }

  Column buildEyesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Eye Color",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: eyesController,
          decoration: InputDecoration(
            hintText: "Update Eye Color",
            errorText: _eyesValid ? null : "Input too long",
          ),
        )
      ],
    );
  }

  Column buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Height",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: heightController,
          decoration: InputDecoration(
            hintText: "Update Height",
            errorText: _heightValid ? null : "Input too long",
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      ageController.text.trim().length > 3
          ? _ageValid = false
          : _ageValid = true;
      hairController.text.trim().length < 3 || hairController.text.isEmpty
          ? _hairValid = false
          : _hairValid = true;
      eyesController.text.trim().length < 3 || eyesController.text.isEmpty
          ? _eyesValid = false
          : _eyesValid = true;
      heightController.text.trim().length > 4 || heightController.text.isEmpty
          ? _heightValid = false
          : _heightValid = true;
    });

    if (_displayNameValid &&
        _ageValid &&
        _hairValid &&
        _eyesValid &&
        _heightValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "age": ageController.text,
        "eyeColor": eyesController.text,
        "hairColor": hairController.text,
        "height": heightController.text,
      });
      // SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      // _scaffoldKey.currentState?.showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider(user!.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildAgeField(),
                            buildHairField(),
                            buildEyesField(),
                            buildHeightField(),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: updateProfileData,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextButton.icon(
                          onPressed: logout,
                          icon: Icon(Icons.cancel, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
