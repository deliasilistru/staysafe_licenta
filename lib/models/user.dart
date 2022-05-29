import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String eyeColor;
  final String hairColor;
  final String height;
  final String age;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.eyeColor,
    required this.hairColor,
    required this.height,
    required this.age,
  });

  factory User.fromDocument(DocumentSnapshot document) {
    return User(
      id: document['id'],
      username: document['username'],
      email: document['email'],
      photoUrl: document['photoUrl'],
      displayName: document['displayName'],
      eyeColor: document['eyeColor'],
      hairColor: document['hairColor'],
      height: document['height'],
      age: document['age'],
    );
  }
}
