import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter_star_rating/flutter_star_rating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          displayBook(snapshot),
                          bookDetailsOne(snapshot),
                        ],
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                }),
          ),
          Container(
            child: FutureBuilder(
                future: getAuthorSnapshot(id),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[authorDetails(snapshot)],
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                }),
          ),
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          authorCommentary(snapshot),
                        ],
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                }),
          ),
          Container(
            child: FutureBuilder(
                future: getLovedList(id),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          listAddition(snapshot, id),
                        ],
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                }),
          ),
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

Future<DocumentSnapshot> getAuthorSnapshot(String id) async {
  DocumentSnapshot bookSnap =
      await Firestore.instance.collection('Books').document(id).get();

  DocumentSnapshot snapshot = await Firestore.instance
      .collection('Users')
      .document(bookSnap.data['Owner'])
      .get();

  return snapshot;
}

Future<bool> getLovedList(String id) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();

  DocumentSnapshot snapshot = await Firestore.instance
      .collection('Users')
      .document(user.uid)
      .collection('Lists')
      .document('Loved')
      .get();

  if (snapshot.data == null) {
    return false;
  } else {
    return true;
  }

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

Widget bookDetailsOne(AsyncSnapshot snapshot) {
  return Container(
      child: Row(
    children: <Widget>[
      Expanded(
          child: Column(
        children: <Widget>[
          Text("Condition: " + snapshot.data['Condition']),
          Text("Edition: " + snapshot.data['Edition'])
        ],
      )),
      Expanded(
          child: Column(
        children: <Widget>[
          Text('Price: \$' + snapshot.data['Price'].toString()),
          Text('ISBN#: ' + snapshot.data['ISBN-10'])
        ],
      ))
    ],
  ));
}

Widget authorDetails(AsyncSnapshot snapshot) {
  double userRating = snapshot.data['rating'].toDouble();
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
            child: Column(
          children: <Widget>[
            Text('Seller: ' + snapshot.data['username']),
          ],
        )),
        Expanded(
            child: Column(children: <Widget>[
          ConditionalBuilder(
              condition: (snapshot.data['rating'] != 0),
              builder: (context) => Container(
                    child: StarRating(
                        rating: userRating,
                        starConfig: StarConfig(
                          size: 15.0,
                        )),
                  ))
        ]))
      ],
    ),
  );
}

Widget authorCommentary(AsyncSnapshot snapshot) {
  return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
            children: <Widget>[
              Text('Seller Notes'),
              Text('-' + snapshot.data['Commentary']),
            ],
          )),
        ],
      ));
}

Widget listAddition(AsyncSnapshot snapshot, String id) {
  return Container(
      child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ConditionalBuilder(
              condition: (snapshot.data == true),
              builder: (context) => Container(
                  child: IconButton(
                      icon: Icon(Icons.favorite),
                      color: Colors.red,
                      onPressed: () => {removeFromLoved(id)}))),
          ConditionalBuilder(
              condition: (snapshot.data == false),
              builder: (context) => Container(
                  child: IconButton(
                      icon: Icon(Icons.favorite_border),
                      color: Colors.red,
                      onPressed: () => addToLoved(id)))),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Colors.black,
            onPressed: () => addToCart(id),
          ),
          //Text('Add to Cart'),
        ],
      ),
    ],
  ));
}

addToLoved(String id) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();

  await Firestore.instance
      .collection('Users')
      .document(user.uid)
      .collection('Lists')
      .document('Loved')
      .setData({
    id: id,
  }, merge: true).then((_) {
    print('Success');
  });
}

removeFromLoved(String id) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  String uid = user.uid.toString();

  await Firestore.instance
      .collection('Users')
      .document(uid)
      .collection('Lists')
      .document('Loved')
      .updateData({id: FieldValue.delete()}).then((_) {
    print('Success');
  });
}

addToCart(String id) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();

  await Firestore.instance
      .collection('Users')
      .document(user.uid)
      .collection('Lists')
      .document('Cart')
      .setData({
    id: id,
  }, merge: true).then((_) {
    print('Success');
  });
}