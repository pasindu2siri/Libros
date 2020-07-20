import 'package:Libros/screens/navigator.dart';
import 'package:flutter/material.dart';
import 'package:Libros/services/auth.dart';
import 'package:Libros/pages/login.dart';
import 'package:Libros/providers/authProvider.dart';

class RootPage extends StatelessWidget {
  const RootPage({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProvider.of(context).auth;
    return StreamBuilder<String>(
        stream: auth.onAuthStateChange,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final bool isLoggedIn = snapshot.hasData;
            return isLoggedIn ? App() : LoginPage();
          }
          return _buildWaitingScreen();
        });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
