import 'package:flutter/material.dart';

AppBar header(
  context, {
  bool isAppTitle = false,
  String titleText = "",
  removeBackButton = true,
  isProfilePage = false,
}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "StaySafe" : titleText,
      style: TextStyle(
        color: Colors.black,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
    ),
    // actions: <Widget>[
    //   IconButton(
    //       tooltip: 'Go to the next page',
    //       onPressed: () {
    //         Navigator.push(context, MaterialPageRoute<void>(
    //           builder: (BuildContext context) {
    //             return Scaffold(
    //               appBar: AppBar(
    //                 title: const Text('Next page'),
    //               ),
    //               body: const Center(
    //                 child: Text(
    //                   'This is the next page',
    //                   style: TextStyle(fontSize: 24),
    //                 ),
    //               ),
    //             );
    //           },
    //         ));
    //       },
    //       icon: const Icon(Icons.people))
    // ],
    centerTitle: true,
    //backgroundColor: Theme.of(context).colorScheme.secondary,
    backgroundColor: Colors.white,
  );
}
