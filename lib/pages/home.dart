import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Libros/providers/authProvider.dart';
import 'package:Libros/services/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libros'),
        actions: <Widget>[
          FlatButton(child: Text('Logout'), onPressed: () => _signOut(context)),
        ],
      ),
      body: FutureBuilder(
        future: getUserSnapshot(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return createLogo();
            }
          } else if (snapshot.hasError) {
            return Text('no data');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

Future<DocumentSnapshot> getUserSnapshot() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  String uid = user.uid.toString();

  DocumentSnapshot snapshot =
      await Firestore.instance.collection('Users').document(uid).get();

  print(snapshot.data.toString());
  return snapshot;
}

Future<void> _signOut(BuildContext context) async {
  try {
    final BaseAuth auth = AuthProvider.of(context).auth;
    await auth.signOut();
  } catch (e) {
    print(e);
  }
}

Widget createLogo() {
  return Container(
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/Libro_Logo_1.png'),
          )));
}
