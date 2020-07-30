import 'package:Libros/pages/bookView.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder/conditional_builder.dart';

class BookListView extends StatelessWidget {
  // Declare a field that holds the Person data
  final String bookTitle;
  final String uid;

  // In the constructor, require a Person
  BookListView({Key key, @required this.bookTitle, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Libros'),
        ),
        body: Column(children: <Widget>[
          Container(
            child: FutureBuilder(
              future: createBuyableBooks(bookTitle),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return displayBooks(snapshot, uid);
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

Future<List<Map<String, dynamic>>> createBuyableBooks(String bookTitle) async {
  List<DocumentSnapshot> docs;
  List<Map<String, dynamic>> list = new List();

  await Firestore.instance
      .collection('Books')
      .where("Title", isEqualTo: bookTitle)
      .getDocuments()
      .then((query) {
    docs = query.documents;
  });

  list = docs.map((DocumentSnapshot docSnapshot) {
    return docSnapshot.data;
  }).toList();

  return list;
}

Widget displayBooks(AsyncSnapshot asyncSnapshot, String uid) {
  List<Map<String, dynamic>> books = asyncSnapshot.data ?? [];

  return Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: books.length,
          itemBuilder: (context, index) {
            return new Container(
              margin: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: new Column(
                children: <Widget>[
                  new Align(
                    child: new Text(
                      books[index]['Title'],
                      style: new TextStyle(fontSize: 20.0),
                    ), //so big text
                    alignment: FractionalOffset.topLeft,
                  ),
                  new Divider(
                    color: Colors.blue,
                  ),
                  new Align(
                    child: new Text("Author: " + books[index]['Author']),
                    alignment: FractionalOffset.topLeft,
                  ),
                  new Divider(
                    color: Colors.blue,
                  ),
                  new Align(
                    child: new Text("Condition: " + books[index]['Condition']),
                    alignment: FractionalOffset.topLeft,
                  ),
                  new Divider(
                    color: Colors.red,
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("Price: \$" + books[index]['Price'].toString()),
                      new Container(
                          child: ConditionalBuilder(
                              condition: (uid != books[index]['Owner']),
                              builder: (context) => Container(
                                      child: new FlatButton(
                                    child: new Text(
                                      "View Book",
                                      style: new TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => BookView(
                                              id: books[index]['id'].toString(),
                                              bookTitle: books[index]['Title']
                                                  .toString())),
                                    ),
                                  )))),
                    ],
                  ),
                ],
              ),
            );
          }));
}
