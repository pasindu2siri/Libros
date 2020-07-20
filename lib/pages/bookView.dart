import 'package:Libros/pages/bookListView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookView extends StatelessWidget {
  final String id;
  final String bookTitle;

  BookView({Key key, @required this.id, @required this.bookTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(bookTitle),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: FutureBuilder(
                future: getBookSnapshot(id),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return displayBook(snapshot);
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                }),
          )
        ],
      ),
    );
  }
}

Future<DocumentSnapshot> getBookSnapshot(String id) async {
  DocumentSnapshot snapshot =
      await Firestore.instance.collection('Books').document(id).get();

  return snapshot;
}

Widget displayBook(AsyncSnapshot snapshot) {
  return Container(
     decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
     Image.asset('assets/images/book.jpg'),
    ],
  ));
}
