import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/models/google_user_profile.dart';
import 'package:flutter_google_apis/network_call/api_services.dart';
//import 'package:flutter_google_apis/ui/MailsScreen.dart';
import 'package:flutter_google_apis/ui/mail_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'profile',
    'https://mail.google.com/'
  ],
);

class _LoginScreenState extends State<LoginScreen> {
  GoogleUserProfile googleUserProfile = new GoogleUserProfile();
  bool isLoggedIn = false;
  SharedPreferences sharedPreference;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPreference){
      this.sharedPreference=sharedPreference;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GoogleSignInButton(
          onPressed: () {signInWithGoogle();},
          darkMode: true, // default: false
        ),
//        child: RaisedButton(
//          child: Text("sign in"),
//          onPressed: () {
//
//          },
//        ),
      ),
    );
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleSignInAccount googleSignInAccount;

  Future<String> signInWithGoogle() async {
    googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await _auth.currentUser();
    googleUserProfile = GoogleUserProfile.fromJson(_googleSignIn.currentUser);
    assert(user.uid == currentUser.uid);
    Map<String, String> authHeaders= await googleUserProfile.authHeaders;
    print("Head: $authHeaders");
    String headers = json.encode(authHeaders);
    print("Head json: $headers");
    if(mounted)
      {
        setState(() {
          sharedPreference.setBool(ApiConstants.IS_USER_LOGGED_IN, true);
          googleUserProfile = GoogleUserProfile.fromJson(googleSignInAccount);
          sharedPreference.setString(ApiConstants.loggedInUserName, googleUserProfile.displayName);
          sharedPreference.setString(ApiConstants.loggedInUserId, googleUserProfile.id);
          sharedPreference.setString(ApiConstants.loggedInUserMail, googleUserProfile.email);
          sharedPreference.setString(ApiConstants.loggedInUserProfile, googleUserProfile.photoUrl);
          sharedPreference.setString(ApiConstants.authHeaders, headers);
        });
      }

//    Navigator.push(context, MaterialPageRoute(builder: (context) => MailsScreen(googleUserProfile: googleUserProfile)));
    Navigator.push(context, MaterialPageRoute(builder: (context) => MailsScreen(googleUserProfile: googleUserProfile, googleSignInAccount: googleSignInAccount)));
    return 'signInWithGoogle succeeded: $user';
  }

  /*_sendEmail(GoogleSignInAccount googleSignInAccount){
    googleSignInAccount.authHeaders.then((result) {
      var header = {'Authorization': result['Authorization'], 'X-Goog-AuthUser': result['X-Goog-AuthUser']};
      ApiServices().testingEmail(googleSignInAccount.email, header);
    });
  }*/

  void signOutGoogle() async{
    await _googleSignIn.signOut();
    print("User Sign Out");
  }
}

