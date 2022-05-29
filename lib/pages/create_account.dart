import 'package:flutter/material.dart';

import '../widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username = "";

  submit() {
    final form = _formKey.currentState;
    if (form != null) {
      if (form.validate()) {
        form.save();
        Navigator.pop(context, username);
      }
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: header(context,
            titleText: "Set up your profile", removeBackButton: true),
        body: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                        "Create a username",
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: TextFormField(
                            validator: (val) {
                              if (val != null) {
                                if (val.trim().length < 3 || val.isEmpty) {
                                  return "Username too short";
                                } else if (val.trim().length > 20) {
                                  return "Username too long";
                                }
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => username = val!,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Username",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Must be at least 3 characters",
                            )),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
