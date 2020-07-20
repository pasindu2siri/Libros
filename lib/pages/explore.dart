import 'package:Libros/models/books.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Libros/pages/bookListView.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController editingController = TextEditingController();

  final duplicateItems = List<String>();
  var items = List<String>();
  var finalDistinct = List<String>();

  @override
  void initState() {
    getBookListSnapshot();
    items.addAll(duplicateItems);
    super.initState();
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.toLowerCase().trim().contains(query.toLowerCase().trim())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
    items.clear();
  }

  getBookListSnapshot() async {
    var temp1 = List<String>();
    var temp2 = List<String>();

    await Firestore.instance.collection('Books').getDocuments().then((query) {
      query.documents.forEach((result) {
        temp1.add(result.data["Title"].toString().toLowerCase().trim());
        temp2.add(result.data['Title'].toString());
      });
    });
    var distinct = temp1.toSet().toList();
    finalDistinct = temp2.toSet().toList();

    for (var book in distinct) {
      duplicateItems.add(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${items[index]}'),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      color: Colors.green,
                      onPressed: () => sendToNewPage(
                          context, items[index].toString(), finalDistinct),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

sendToNewPage(BuildContext context, String book, List<String> distincts) {
  for (var bookTitle in distincts) {
    if (bookTitle.toLowerCase().trim() == book) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => BookListView(bookTitle: bookTitle)),
      );
    }
  }
}
