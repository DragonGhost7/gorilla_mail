import 'package:flutter/material.dart';
import 'package:gorilla_mail/models/email.dart';

class EmailScreen extends StatelessWidget {
  final Email email;

  EmailScreen(this.email);

  @override
  Widget build(BuildContext context) {
    //email.fetchMailByID(email.id, sidToken);
    return Scaffold(
      appBar: AppBar(title: Text(email.subject)),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Text(email.contents),
          //Header()
        ],
      )),
    );
  }
}
