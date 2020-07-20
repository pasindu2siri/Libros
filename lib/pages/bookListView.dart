import 'package:Libros/pages/bookView.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookListView extends StatelessWidget {
  // Declare a field that holds the Person data
  final String bookTitle;

  // In the constructor, require a Person
  BookListView({Key key, @required this.bookTitle}) : super(key: key);

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
                    return displayBooks(snapshot);
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

Widget displayBooks(AsyncSnapshot asyncSnapshot) {
  List<Map<String, dynamic>> books = asyncSnapshot.data ?? [];

  return Container(
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
                    color: Colors.red[300],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text("Price: \$" + books[index]['Price'].toString()),
                      new FlatButton(
                          onPressed: () {},
                          child: IconButton(
                              icon: Icon(Icons.favorite),
                              color: Colors.red,
                              onPressed: () => {})),
                      new FlatButton(
                        child: new Text(
                          "View Book",
                          style: new TextStyle(color: Colors.black),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BookView(
                                  id: books[index]['id'].toString(),
                                  bookTitle: books[index]['Title'].toString())),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          }));
}
