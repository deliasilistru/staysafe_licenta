import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staysafe_licenta/pages/create_account.dart';
import 'package:staysafe_licenta/pages/profile.dart';
import 'package:staysafe_licenta/pages/search.dart';
import 'package:staysafe_licenta/pages/sos.dart';
import '../models/user.dart';
import 'activity_feed.dart';
import 'alerts.dart';
import 'map.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final contactsRef = FirebaseFirestore.instance.collection('contacts');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final contactsAlertsRef = FirebaseFirestore.instance.collection('alerts');
final DateTime timestamp = DateTime.now();
User? currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 2);
    googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        handleSignIn(account);
      }
    }, onError: (err) {
      print('Error signing in: $err');
    });
    //Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      if (account != null) {
        handleSignIn(account);
      }
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot document = await usersRef.doc(user?.id).get();

    if (!document.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from creat account, use it to make new user document in users collection

      usersRef.doc(user?.id).set({
        "id": user?.id,
        "username": username,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "age": " ",
        "eyeColor": " ",
        "hairColor": " ",
        "height": " ",
        "timestamp": timestamp,
      });

      document = await usersRef.doc(user?.id).get();
    }

    currentUser = User.fromDocument(document);

    print(currentUser?.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
    setState(() {
      isAuth = false;
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          ActivityFeed(),
          Alerts(),
          Sos(),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.adjust_rounded,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
    );
    // return ElevatedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'StaySafe',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90.0, color: Colors.white),
            ),
            GestureDetector(
                onTap: login,
                child: Container(
                  width: 260.0,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/google_signin_button.png'),
                        fit: BoxFit.cover),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isAuth == true) {
      return buildAuthScreen();
    } else {
      return buildUnAuthScreen();
    }
    //return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}

showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}

showMap(BuildContext context,
    {required double latitude_user, required double longitude_user}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LocationMap(
        latitude_contact: latitude_user,
        longitude_contact: longitude_user,
      ),
    ),
  );
}
