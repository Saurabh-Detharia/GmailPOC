import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/network_call/google_http_client.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReplyScreen extends StatefulWidget {

  final String subject;
  final Message message;
  final String sender;

  ReplyScreen(this.subject, this.message, this.sender);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {

  GoogleHttpClient httpClient;
  TextEditingController toController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController composeMailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController ccController = TextEditingController();
  TextEditingController bccController = TextEditingController();
  SharedPreferences sharedPreference;
  String loggedInUserName = "";
  String loggedInUserProfile = "";
  String loggedInUserMail = "";
  Map<String, dynamic> authHeaders;
  bool isExpanded = false;
  String selValue = "1";
  var res;

  final List<DropdownMenuItem> _mailIds = [
    DropdownMenuItem<String>(
      value: "1",
      child: Text(
        "",
        style: TextStyle(color: Colors.white),
      ),
    ),
    DropdownMenuItem<String>(
      value: "2",
      child: Text(
        "",
        style: composeMailText,
      ),
    ),
    DropdownMenuItem<String>(
      value: "3",
      child: Text(
        "",
        style: composeMailText,
      ),
    ),
    DropdownMenuItem<String>(
      value: "4",
      child: Text(
        "",
        style: composeMailText,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPreferences) {
      this.sharedPreference = sharedPreferences;
      if (sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
        if (mounted &&
            sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
          setState(() {
            loggedInUserProfile =
                sharedPreferences.getString(ApiConstants.loggedInUserProfile);
            loggedInUserName =
                sharedPreferences.getString(ApiConstants.loggedInUserName);
            loggedInUserMail =
                sharedPreferences.getString(ApiConstants.loggedInUserMail);
            toController.text = loggedInUserMail;
            res = jsonDecode(sharedPreference.getString(ApiConstants.authHeaders));
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    subjectController.text = "Re: " + widget.subject;
    fromController.text =  widget.sender;

    return Container(
      color: ColorAssets.themeColorBlue,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: ColorAssets.themeColorWhite,
          appBar: AppBar(
            backgroundColor: ColorAssets.themeColorBlue,
            // This is for back navigation
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Icon(
                    Icons.close,
                    color: ColorAssets.themeColorWhite,
                  )),
            ),

            // This is for quick actions
            actions: <Widget>[
              // This is to attach media
              Container(
                padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  ImageAssets.attachment,
                  height: 20.0,
                  width: 20.0,
                ),
              ),

              // This is to send email
              Container(
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    _sendMail();
                  },
                  child: Image.asset(
                    ImageAssets.send_icon,
                    height: 20.0,
                    width: 20.0,
                  ),
                ),
              ),

              // This is for menu
              Container(
                width: 20.0,
                margin: EdgeInsets.only(right: 10.0),
                padding: EdgeInsets.only(top: 17.0, bottom: 17.0),
                child: Image.asset(
                  ImageAssets.menu_dot,
                  height: 20.0,
                  width: 20.0,
                ),
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[

                // To field
                Container(
                  height: 50.0,
                  child: TextFormField(
                    controller: toController,
                    style: composeMailText,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "To",
                      hintStyle: composeMailText,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: Icon(
                          isExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: ColorAssets.greyText,
                        ),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),

                // Cc field
                Visibility(
                  visible: !isExpanded,
                  child: Container(
                    color: ColorAssets.themeColorGrey,
                    height: 1,
                  ),
                ),

                // Bcc field
                Visibility(
                  visible: isExpanded,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 40.0,
                        alignment: Alignment.bottomCenter,
                        child: TextFormField(
                          controller: ccController,
                          keyboardType: TextInputType.emailAddress,
                          style: composeMailText,
                          decoration: InputDecoration(
                            hintText: "Cc",
                            hintStyle: composeMailText,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(0.0),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 50.0,
                        child: TextFormField(
                          controller: bccController,
                          style: composeMailText,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              hintText: "Bcc",
                              hintStyle: composeMailText,
                              focusedBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: ColorAssets.themeColorGrey
                                          .withOpacity(0.8))),
                              border: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: ColorAssets.themeColorGrey
                                          .withOpacity(0.8)))),
                        ),
                      )
                    ],
                  ),
                ),

                // From field
                Container(
                    height: 50.0,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "From",
                              style: composeMailText,
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 5.0),
                                child: TextFormField(
                                  controller: fromController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: messageDesStyle,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: ColorAssets.greyText,
                              ),
                            )
/*                         DropdownButtonHideUnderline(
                           child: DropdownButton(
                             icon: Container(
                               height: 30.0,
                               width: 30.0,
                               margin: EdgeInsets.only(right: 10.0),
                               child: Icon(Icons.arrow_drop_down,color: ColorAssets.greyText,),
                             ),
                             iconEnabledColor: ColorAssets.greyText,
                             iconDisabledColor: ColorAssets.greyText,
                             isDense: true,
                             value: "$selValue",
                             onChanged: (newValue) {
                               if(!mounted){
                                 return;
                               }
                               setState(() {
                                 selValue = newValue;
                               });
                             },
                             items: _mailIds,

                           ),
                         )*/
                          ],
                        ),
                        Container(
                          color: ColorAssets.themeColorGrey,
                          height: 1,
                        )
                      ],
                    )),

                // Subject field
                Container(
                  height: 50.0,
                  child: TextFormField(
                    controller: subjectController,
                    style: composeMailText,
                    decoration: InputDecoration(
                        hintText: "Subject",
                        hintStyle: sujectStyle,
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                                color: ColorAssets.themeColorGrey
                                    .withOpacity(0.8))),
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                                color: ColorAssets.themeColorGrey
                                    .withOpacity(0.8)))),
                  ),
                ),

                // Content field
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: TextFormField(
                      controller: composeMailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 10,
                      style: writeMailStyle,
                      decoration: InputDecoration(
                        hintText: "Compose mail",
                        hintStyle: writeMailStyle,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0.0),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // This is to validate content of the fields
  _sendMail() {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    if (toController.text.toString().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter receiver's email address",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (!regex.hasMatch(toController.text.toString())) {
      Fluttertoast.showToast(
        msg: "Please enter receiver's valid email address",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (fromController.text.toString().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your email address",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (!regex.hasMatch(fromController.text.toString())) {
      Fluttertoast.showToast(
        msg: "Please enter your valid email address",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (ccController.text.toString().isNotEmpty && !regex.hasMatch(ccController.text.toString())) {
      Fluttertoast.showToast(
        msg: "Please enter valid Cc email address",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (bccController.text.toString().isNotEmpty && !regex.hasMatch(bccController.text.toString())) {
      Fluttertoast.showToast(
        msg: "Please enter valid Bcc email address",
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (composeMailController.text.toString().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your message",
        toastLength: Toast.LENGTH_LONG,
      );
    } else {

      Map<String, String> headers= new Map();
      for(int k=0; k<res.length; k++) {
        headers["Authorization"] = res["Authorization"];
        headers["X-Goog-AuthUser"] = res["X-Goog-AuthUser"];
      }

      String from = fromController.text.toString();
      String to = toController.text.toString();
      String sub = "Re: ${widget.subject}";
      String message = composeMailController.text.toString();
      String cc = ccController.text.toString();
      String bcc = bccController.text.toString();

      sendEmail(loggedInUserMail, headers, from, to, cc, bcc, sub, message);
    }
  }

  // This is to send email
  Future<Null> sendEmail(String userId, Map header, String from, String to, String cc, String bcc, String sub, String message) async {
    header['Accept'] = 'application/json';
    header['Content-type'] = 'application/json';
    header['To'] = userId;


    var content = "From: $from\nTo: $to\nbcc: $from\nSubject: $sub\nMessage-ID: ${widget.message.id}\nIn-Reply-To: ${widget.sender}\n\n$message";

    var bytes = utf8.encode(content);
    var base64 = base64UrlEncode(bytes);
    base64 = base64.replaceAll("+", "-").replaceAll("/", "_").substring(0, base64.length-1);
    var body = json.encode({'raw': base64});

    httpClient = GoogleHttpClient(header);

    String url = 'https://www.googleapis.com/gmail/v1/users/' + userId + '/messages/send';

    final http.Response response =
    await http.post(url, headers: header, body: body);
    if (response.statusCode != 200) {
      print('error: ' + response.statusCode.toString());
      print(url);
      print(json.decode(response.body));
      return;
    } else {
      Fluttertoast.showToast(
        msg: "Email sent successfully.",
        toastLength: Toast.LENGTH_LONG,
      );
      _clearText();
    }
    final Map<String, dynamic> data = json.decode(response.body);
    print('ok: ' + response.statusCode.toString());
    print(data);
  }

  // This is to clear all the fields
  _clearText() {
    bccController.clear();
    ccController.clear();
    composeMailController.clear();
    subjectController.clear();
    toController.clear();
  }
}
