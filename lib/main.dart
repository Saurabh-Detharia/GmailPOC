import 'package:flutter/material.dart';
import 'package:flutter_google_apis/ui/login_screen.dart';
import 'package:flutter_google_apis/ui/mail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gloabal/api_constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences sharedPreferences;
  bool isLogin;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPreferences) {
      setState(() {
        this.sharedPreferences = sharedPreferences;
        isLogin = sharedPreferences.getBool(ApiConstants.IS_USER_LOGGED_IN);
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       primarySwatch: Colors.blue,
          //visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: getLoginRedirection(sharedPreferences, isLogin),
    );
  }


  Widget getLoginRedirection(SharedPreferences sharedPreferences, bool isLogin){
    if (sharedPreferences == null) {
      return Container();
    }
    else {
      if (isLogin != null && isLogin == true) {
        return MailsScreen();
      }
      else {
        return LoginScreen();
      }
    }
  }

}
