import 'package:Libros/services/auth.dart';
import 'package:Libros/providers/authProvider.dart';
import 'package:flutter/material.dart';


class LoginSupportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginSupportPageState();
}

class _LoginSupportPageState extends State<LoginSupportPage> {
  
  TextEditingController inputtextField = TextEditingController();

    @override
      Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Login Support'),
          ),
          body: Container(
        padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,   
            children: buildValues(),
          ),        
        ),
      );
    }



   List<Widget> buildValues(){
     return <Widget>[
      Text('In order to change your password, we need to verify your identity. Enter the email address associated with your LiBros account.'),
      
      TextFormField(      
        controller: inputtextField,
        decoration: InputDecoration(labelText: 'Email'),
      ),
      RaisedButton(
        onPressed: () => validate(inputtextField.text, this.context),
        child: Text('Continue'),
      ),
      RaisedButton(onPressed: ()=> Navigator.pop(this.context),
      child: Text('Back to Login Page'),)
    ];
  }
  
  validate(String value, BuildContext context) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      print('nope');
    } else {
      try{
        final BaseAuth auth = AuthProvider.of(context).auth;
        auth.resetPassword(value);
        sendUserToast(context);
        inputtextField.clear();
        
      }catch (e){
       print('lo');
      }
   }
  }


  sendUserToast(BuildContext context){
    Widget okButton = FlatButton(
      child: Text("Close"),
      onPressed: () {
        Navigator.pop(context);
      }
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Reset Password"),
      content: Text('A verification email has been sent to your provided email. Follow the direction in the email to reset your password'),    actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

