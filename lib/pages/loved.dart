import 'package:Libros/pages/bookView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LovedPage extends StatefulWidget {
  const LovedPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LovedPageState();
}

class _LovedPageState extends State<LovedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Loved Items'),
        ),
        body: Column(children: <Widget>[
          Container(
            child: FutureBuilder(
              future: createLovedBooks(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return displayLovedBooks(snapshot);
                  }
                } else if (snapshot.hasError) {
                  return Text('no data');
                }
                return CircularProgressIndicator();
              },
            ),
          )
        ]));
  }
}

Widget displayLovedBooks(AsyncSnapshot asyncSnapshot) {
  List<Map<String, dynamic>> lovedBooks = asyncSnapshot.data ?? [];

  return Expanded(
    child: GridView.builder(
      padding: const EdgeInsets.all(4.0),
      shrinkWrap: true,
      itemCount: lovedBooks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 5.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: Card(
              shape: RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(15.0)),
              child: Column(
                children: <Widget>[
                  Text(lovedBooks[index]['Title']),
                  Image.asset('assets/images/book.jpg'),
                  Text('data'),
                  RaisedButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => BookView(
                                id: lovedBooks[index]['id'],
                                bookTitle: lovedBooks[index]['Title']))),
                    child: Text('View Book'),
                  )
                ],
              )),
        );
      },
    ),
  );
}

Future<List<Map<String, dynamic>>> createLovedBooks() async {
  List<String> idList = new List();
  List<Map<String, dynamic>> lovedBooks = new List();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  String uid = user.uid.toString();

  DocumentSnapshot lovedId = await Firestore.instance
      .collection('Users')
      .document(uid)
      .collection('Lists')
      .document('Loved')
      .get();

  for (var item in lovedId.data.values) {
    idList.add(item.toString());
  }

  for (var item in idList) {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('Books')
        .document(item.toString())
        .get();

    final Map<String, dynamic> bookMap = snapshot.data;
    lovedBooks.add(bookMap);
  }

  return lovedBooks;
}
