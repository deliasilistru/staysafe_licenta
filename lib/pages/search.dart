import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:staysafe_licenta/widgets/progress.dart';
import '../models/user.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  List<User> results = [];

  Future<void> handleSearch(String query) async {
    Future<QuerySnapshot> users = usersRef
        .where("displayName".toLowerCase(), arrayContains: query.toLowerCase())
        .get();
    QuerySnapshot querySnapshot = await usersRef.get();
    List<User> allUsers =
        querySnapshot.docs.map((e) => User.fromDocument(e)).toList();

    setState(() {
      results.addAll(allUsers.where((element) {
        if (element.displayName.contains(query)) {
          return true;
        } else {
          if (element.username.contains(query)) {
            return true;
          } else {
            return false;
          }
        }
      }));
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    setState(() {
      searchController.clear();
      results.clear();
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
        onChanged: (string) {
          setState(() {
            results.clear();
          });
        },
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    // return FutureBuilder(
    //     future: searchResultsFuture,
    //     builder: (context, AsyncSnapshot snapshot) {
    //       if (!snapshot.hasData) {
    //         return circularProgress();
    //       }
    //       List<UserResult> searchResults = [];
    //       snapshot.data?.docs.forEach((document) {
    //         User user = User.fromDocument(document);
    //         UserResult searchResult = UserResult(user);
    //         searchResults.add(searchResult);
    //       });
    //       return ListView(
    //         children: searchResults,
    //       );
    //     });

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, index) {
        return UserResult(results[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Theme.of(context).primaryColor.withOpacity(0.7),
      color: Colors.grey.withOpacity(0.2),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
