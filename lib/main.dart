import 'package:flutter/material.dart';
import 'package:Libros/services/auth.dart';
import 'package:Libros/providers/authProvider.dart';
import 'package:Libros/screens/root.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Libros',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RootPage(),
      ),
    );
  }
}