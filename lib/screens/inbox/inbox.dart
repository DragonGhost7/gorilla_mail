import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gorilla_mail/app.dart';
import 'package:gorilla_mail/models/email.dart';
import 'package:http/http.dart' as http;

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  String token;
  bool showAlias = false;
  var data;
  int timestamp;
  String alias;
  List emails = [];
  String address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Inbox"),
          actions: [
            IconButton(
                icon: Icon(Icons.restore_from_trash),
                onPressed: () => _forgetMe())
          ],
        ),
        floatingActionButton: this.token != null
            ? FloatingActionButton(
                child: Icon(Icons.download_sharp),
                onPressed: () {
                  _getEmails();
                },
              )
            : FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  _initInbox();
                }),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
                onTap: () => this.setState(() {
                      showAlias = !showAlias;
                    }),
                onLongPress: () => this.copyToClipboard(),
                child: Container(
                    margin: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: this.token != null
                        ? showAlias
                            ? Text(
                                this.alias + "@" + this.address.split("@")[1])
                            : Text(this.address)
                        : Text("Adress isnt set yet"),
                    height: 60.0,
                    decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10.0)))),
            Expanded(
                child: Container(
              child: ListView(
                children: this
                    .emails
                    .map((email) => GestureDetector(
                          child: Container(
                            height: 60,
                            child: Text(email.subject),
                          ),
                          onTap: () => _onEmailTap(context, email),
                        ))
                    .toList(),
              ),
            ))
          ],
        ));
  }

  void _onEmailTap(BuildContext context, Email email) {
    Navigator.pushNamed(context, EmailRoute, arguments: {"email": email});
  }

  Future<String> _getEmailContents(Email email) async {
    var response = await http.get(
        "https://api.guerrillamail.com/ajax.php?f=fetch_email&sid_token=" +
            this.token +
            "&email_id=" +
            email.id.toString());
    var data = jsonDecode(response.body);
    print(data);
    email.contents = data['mail_body'];

    return "Success";
  }

  void _initInbox() {
    print("Inbox initiated");

    _getEmailAddress();
  }

  Future<String> _getEmailAddress() async {
    var response = await http
        .get("https://api.guerrillamail.com/ajax.php?f=get_email_address");
    this.setState(() {
      data = jsonDecode(response.body);
    });

    print(data);
    this.address = data['email_addr'].toString();
    this.timestamp = data['email_timestamp'];
    this.alias = data['alias'];
    this.token = data['sid_token'];

    return "Success";
  }

  Future<String> _getEmails() async {
    var response = await http.get(
        "https://api.guerrillamail.com/ajax.php?f=check_email&sid_token=" +
            this.token +
            "&seq=" +
            this.emails.length.toString());
    data = jsonDecode(response.body);
    for (var entry in data['list']) {
      print(entry);
      this.emails.add(Email(
          entry['mail_id'],
          entry['mail_from'],
          entry['mail_subject'],
          entry['mail_excerpt'],
          entry['mail_timestamp'],
          entry["mail_read"]));
    }

    this.setState(() {});
    for (Email email in this.emails) {
      if (email.contents == null) {
        _getEmailContents(email);
      }
    }
    return "Success";
  }

  Future<String> _forgetMe() async {
    var response = await http.get(
        "https://api.guerrillamail.com/ajax.php?f=forget_me&email_addr=" +
            this.address +
            "&sid_token=" +
            this.token);
    print(jsonDecode(response.body));
    this.address = this.timestamp = this.alias = this.token = null;
    this.emails.clear();
    this.setState(() {});

    return "success";
  }

  void copyToClipboard() {
    Clipboard.setData(showAlias
        ? ClipboardData(text: this.alias + "@" + this.address.split("@")[1])
        : ClipboardData(text: this.address));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('text copied')));
  }
}
