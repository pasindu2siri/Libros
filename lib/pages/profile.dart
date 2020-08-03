import 'package:Libros/pages/loved.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Libros/providers/authProvider.dart';
import 'package:Libros/services/auth.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter_star_rating/flutter_star_rating.dart';
import 'package:Libros/pages/cart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Account Details'),
          actions: <Widget>[
            FlatButton(
                child: Text('Logout'), onPressed: () => _signOut(context)),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: FutureBuilder(
                future: getUserSnapshot(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Container(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                              children: <Widget>[createProfile(snapshot)]));
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
            Container(
              child: FutureBuilder(
                future: getUserReviewsSnapshot(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Container(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                              children: <Widget>[createUserReviews(snapshot)]));
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
            Container(
              child: FutureBuilder(
                future: getUserBooksSnapshot(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Container(
                          padding: EdgeInsets.all(8.0),
                          child: Column(children: <Widget>[
                            createUserBooks(snapshot, width)
                          ]));
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
            Container(
                padding: EdgeInsets.all(16.0),
                child:
                    Column(children: <Widget>[createItemList(context, width)]))
          ],
        ));
  }
}

Widget createProfile(AsyncSnapshot asyncSnapshot) {
  double userRating = asyncSnapshot.data['rating'].toDouble();
  TextStyle _nameTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
  );
  return Container(
    height: 150,
    decoration: BoxDecoration(
        border: Border.all(
      color: Colors.grey,
    )),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Container(
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/profile.jpg'),
                  ))),
        ),
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Container(
                child: Text(
                    asyncSnapshot.data['firstname'] +
                        ' ' +
                        asyncSnapshot.data['lastname'],
                    style: _nameTextStyle),
              ),
              Container(
                child:
                    Text(asyncSnapshot.data['username'], style: _nameTextStyle),
              ),
              ConditionalBuilder(
                  condition: (asyncSnapshot.data['rating'] != 0.0),
                  builder: (context) => Container(
                        child: Text('Rating: ' + userRating.toString(),
                            style: _nameTextStyle),
                      )),
              ConditionalBuilder(
                  condition: (asyncSnapshot.data['rating'] != 0.0),
                  builder: (context) => Container(
                        child: StarRating(
                            rating: userRating,
                            starConfig: StarConfig(
                              size: 15.0,
                            )),
                      ))
            ])),
      ],
    ),
  );
}

Widget createUserReviews(AsyncSnapshot asyncSnapshot) {
  List<Map<String, dynamic>> reviews = asyncSnapshot.data ?? [];
  TextStyle _nameTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
  );
  return Container(
      height: 150,
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ConditionalBuilder(
                condition: (reviews.length != 0),
                builder: (context) => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Reviews', style: _nameTextStyle),
                        for (var item in reviews)
                          SizedBox(
                              width: 360,
                              child: Text(
                                  "''" + item['review'].toString() + "''",
                                  overflow: TextOverflow.ellipsis)),
                      ],
                    ))
          ]));
}

Widget createUserBooks(AsyncSnapshot asyncSnapshot, double width) {
  List<Map<String, dynamic>> books = asyncSnapshot.data ?? [];
  TextStyle _nameTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
  );
  TextStyle _bookTitle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 8.0,
    fontWeight: FontWeight.w700,
  );
  return Container(
      height: 150,
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
      )),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
          Widget>[
        ConditionalBuilder(
            condition: (books.length != 0),
            builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: Text('Books for Sale', style: _nameTextStyle),
                      ),
                      Container(
                          height: 100,
                          width: width - 50,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              for (var item in books)
                                Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.blueAccent)),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                child: Text(
                                                    item['Title'].toString())),
                                            Container(
                                                child: Text('-' +
                                                    item['Author'].toString())),
                                          ])),
                                ),
                            ],
                          ))
                    ]))
      ]));
}

Widget createItemList(BuildContext context, double width) {
  return Container(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.favorite),
                  color: Colors.red,
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LovedPage()))),
              Text('Loved Items'),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.shopping_cart),
                  color: Colors.black,
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CartPage()))),
              Text('My Cart'),
            ],
          ),
        ],
      ));
}

Future<void> _signOut(BuildContext context) async {
  try {
    final BaseAuth auth = AuthProvider.of(context).auth;
    await auth.signOut();
  } catch (e) {
    print(e);
  }
}

Future<DocumentSnapshot> getUserSnapshot() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  String uid = user.uid.toString();

  DocumentSnapshot snapshot =
      await Firestore.instance.collection('Users').document(uid).get();

  return snapshot;
}

Future<List<Map<String, dynamic>>> getUserReviewsSnapshot() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  String uid = user.uid.toString();

  List<DocumentSnapshot> docs;
  List<Map<String, dynamic>> list = new List();

  await Firestore.instance
      .collection('Reviews')
      .where("recievedUserId", isEqualTo: uid)
      .getDocuments()
      .then((query) {
    docs = query.documents;
  });
  list = docs.map((DocumentSnapshot docSnapshot) {
    return docSnapshot.data;
  }).toList();

  return list;
}

Future<List<Map<String, dynamic>>> getUserBooksSnapshot() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  String uid = user.uid.toString();

  List<DocumentSnapshot> docs;
  List<Map<String, dynamic>> list = new List();

  await Firestore.instance
      .collection('Books')
      .where("Owner", isEqualTo: uid)
      .getDocuments()
      .then((query) {
    docs = query.documents;
  });
  list = docs.map((DocumentSnapshot docSnapshot) {
    return docSnapshot.data;
  }).toList();

  return list;
}
