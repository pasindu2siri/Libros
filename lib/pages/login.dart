import 'package:Libros/pages/register.dart';
import 'package:Libros/pages/support.dart';
import 'package:flutter/material.dart';
import 'package:Libros/services/auth.dart';
import 'package:Libros/providers/authProvider.dart';

class EmailFieldValidator {
  static String validate(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    if (value.length < 8) {
      return 'Password not long enough, must be 8 character or more';
    } else {
      return null;
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  String _email;
  String _password;

  bool validateAndSave() {
    final FormState form = _loginFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> sendUserToast(BuildContext context, int x) async {
    Widget okButton = FlatButton(
        child: Text("Close"),
        onPressed: () {
          Navigator.pop(context);
        });

    AlertDialog alert;
    if (x == 1) {
      alert = AlertDialog(
        title: Text("Account Verification"),
        content: Text(
            'It seems that you have not verified your account. A verification email has been sent to your email.'),
        actions: [
          okButton,
        ],
      );
    } else if (x == 2) {
      alert = AlertDialog(
        title: Text("Login Not Successful"),
        content: Text(
            'Please enter valid credentials. If you do not already have a LiBros account, please create one.'),
        actions: [
          okButton,
        ],
      );
    }

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        final BaseAuth auth = AuthProvider.of(context).auth;
        final String userId =
            await auth.signInWithEmailAndPassword(_email, _password);
        if (userId == null) {
          sendUserToast(context, 1);
          auth.signOut();
        } else {
          print('Signed in: $userId');
        }
      } catch (e) {
        sendUserToast(context, 2);
        print('Error: $e');
      }
    }
  }

  Future navigateToNewPage(context, int x) async {
    if (x == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterPage()));
    } else if (x == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginSupportPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libros'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildInputs() + buildSubmitButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    return <Widget>[
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(labelText: 'Email'),
        validator: EmailFieldValidator.validate,
        onSaved: (String value) => _email = value,
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        validator: PasswordFieldValidator.validate,
        onSaved: (String value) => _password = value,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return <Widget>[
      RaisedButton(
        key: Key('signIn'),
        child: Text('Login', style: TextStyle(fontSize: 20.0)),
        onPressed: validateAndSubmit,
      ),
      FlatButton(
        child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
        onPressed: () => navigateToNewPage(context, 1),
      ),
      FlatButton(
        child: Text('Forgot Password', style: TextStyle(fontSize: 20.0)),
        onPressed: () => navigateToNewPage(context, 2),
      ),
    ];
  }
}
