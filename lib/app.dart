import 'package:flutter/material.dart';
import 'package:gorilla_mail/screens/email/email_screen.dart';
import 'screens/inbox/inbox.dart';

const InboxRoute = '/';
const EmailRoute = '/email_screen';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(onGenerateRoute: _routes(),);
  }

  RouteFactory _routes(){
    return (settings) {
      final Map<String,dynamic> arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
        case InboxRoute:
          screen = Inbox();
          break;
        case EmailRoute:
          screen = EmailScreen(arguments['email']);
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }

}

