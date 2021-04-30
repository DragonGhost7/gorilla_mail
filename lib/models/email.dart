import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gorilla_mail/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Email {
  final int id;
  String from;
  String subject;
  String excerpt;
  int timestamp;
  int read;
  String contents;

  Email(this.id, this.from, this.subject, this.excerpt, this.timestamp, this.read);


}
