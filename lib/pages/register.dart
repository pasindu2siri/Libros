import 'package:Libros/models/user.dart';
import 'package:flutter/material.dart';
import 'package:Libros/services/auth.dart';
import 'package:Libros/providers/authProvider.dart';
import 'package:Libros/screens/root.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class MiscFieldValidator {
  static String validate(String value) {
    if (!(value.length > 1)) {
      return 'This field must not be empty';
    } else {
      return null;
    }
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final db = Firestore.instance;

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  TextEditingController userNameInputController;
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  @override
  initState() {
    userNameInputController = new TextEditingController();
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  String _email;
  String _password;

  bool validateAndSave() {
    final FormState form = _registerFormKey.currentState;
    if (pwdInputController.text != confirmPwdInputController.text) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("The passwords do not match"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      print('Passwords do not match');
      return false;
    } else if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> addToDatabase(userId) async {
    //User user = new User(userId, userNameInputController.text, firstNameInputController.text, lastNameInputController.text);
    User user = new User(userId, userNameInputController.text,
        firstNameInputController.text, lastNameInputController.text, 0.0,0);
    await Firestore.instance.collection('Users').document(userId).setData({
      'id': user.uid,
      'username': user.username,
      'firstname': user.firstname,
      'lastname': user.lastname,
      'rating': user.rating,
      'reviewCount': user.reviewCount
    });
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        final BaseAuth auth = AuthProvider.of(context).auth;

        final String userId =
            await auth.createUserWithEmailAndPassword(_email, _password);
        print('Created user: $userId');

        await addToDatabase(userId);
        auth.signOut();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => RootPage()), (r) => false);
      } catch (e) {
        if (e.toString() ==
            'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text(
                      "That email is already in use, please check for a verification email"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Registration'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildInputs() + buildSubmitButtons(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    return <Widget>[
      TextFormField(
        key: Key('username'),
        decoration: InputDecoration(labelText: 'Username'),
        validator: MiscFieldValidator.validate,
        controller: userNameInputController,
      ),
      TextFormField(
        key: Key('firstname'),
        decoration: InputDecoration(labelText: 'First Name'),
        validator: MiscFieldValidator.validate,
        controller: firstNameInputController,
      ),
      TextFormField(
        key: Key('lastname'),
        decoration: InputDecoration(labelText: 'Last Name'),
        validator: MiscFieldValidator.validate,
        controller: lastNameInputController,
      ),
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(labelText: 'Email'),
        validator: EmailFieldValidator.validate,
        onSaved: (String value) => _email = value,
        controller: emailInputController,
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        validator: PasswordFieldValidator.validate,
        onSaved: (String value) => _password = value,
        controller: pwdInputController,
      ),
      TextFormField(
        key: Key('confirm password'),
        decoration: InputDecoration(labelText: 'Confirm Password'),
        obscureText: true,
        validator: PasswordFieldValidator.validate,
        controller: confirmPwdInputController,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return <Widget>[
      RaisedButton(
        key: Key('register'),
        child: Text('Register', style: TextStyle(fontSize: 20.0)),
        onPressed: validateAndSubmit,
      ),
      FlatButton(
        child: Text('Have an account? Login', style: TextStyle(fontSize: 20.0)),
        onPressed: () => Navigator.pop(context),
      ),
    ];
  }
}
