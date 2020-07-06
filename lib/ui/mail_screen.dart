import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/models/google_user_profile.dart';
import 'package:flutter_google_apis/network_call/google_http_client.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:flutter_google_apis/ui/compose_mail.dart';
import 'package:flutter_google_apis/ui/list_row/message_row.dart';
import 'package:flutter_google_apis/ui/message_detail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MailsScreen extends StatefulWidget {

  String accessToken;
  GoogleUserProfile googleUserProfile;
  GoogleSignInAccount googleSignInAccount;

  MailsScreen({this.googleUserProfile, this.googleSignInAccount});

  @override
  _MailsScreenState createState() => _MailsScreenState();
}

class _MailsScreenState extends State<MailsScreen> {

  GoogleHttpClient httpClient;
  ListMessagesResponse listMessagesResponse;
  ListThreadsResponse listThreadsResponse;
  List<Message> messagesList = [];
  List<Thread> threadsList = [];
  bool isMessageSelected=false;
  SharedPreferences sharedPreference;
  GoogleUserProfile googleUserProfile;
  bool isStared = false;
  String loggedInUserName = "";
  String loggedInUserProfile = "";
  String loggedInUserEmail = "";
  Map<String, String> authHeaders = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPreferences) {
      this.sharedPreference = sharedPreferences;

      if (sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
        if (mounted &&
            sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
          setState(() {
          loggedInUserProfile = sharedPreferences.getString(ApiConstants.loggedInUserProfile);
          loggedInUserEmail = sharedPreferences.getString(ApiConstants.loggedInUserMail);
          print("email : "+loggedInUserEmail);
          var res = jsonDecode(sharedPreferences.getString(ApiConstants.authHeaders));
//          print("header" + authHeaders.toString());

            Map<String, String> headers= new Map();
            for(int k=0; k<res.length; k++) {
              headers["Authorization"] = res["Authorization"];
              headers["X-Goog-AuthUser"] = res["X-Goog-AuthUser"];
            }

          getAuthHeaders(headers);


            /* if (sharedPreference.getString(ApiConstants.loggedInUserInfo) != null) {
              googleUserProfile = GoogleUserProfile.fromJson(jsonDecode(
                  sharedPreferences.getString(ApiConstants.loggedInUserInfo)));
              print("user name ===${googleUserProfile.displayName}");
            }*/
          });

        }
      }

    });
  }


  getAuthHeaders(Map<String, String> headers) async{
    httpClient = GoogleHttpClient(headers);
    _callMessageListApi(loggedInUserEmail);
  }

  _callMessageListApi(String email) async {
    await GmailApi(httpClient).users.messages.list(
      email,
    ).then((response){
      if(response != null){
        listMessagesResponse = response;
        print("Message List Api Response: " + listMessagesResponse.toString());
        getFullMessageDetails();
//        _getMessageDetail(widget.googleUserProfile.email, listMessagesResponse.messages[0].id);
      }
    }).catchError((e){
      print("Message List Api Error: " + e.toString());
    });
  }

  void getFullMessageDetails() {
    listMessagesResponse.messages.forEach((message) async {
      await _getMessageDetail(sharedPreference.get(ApiConstants.loggedInUserMail), message.id);
    });
  }

  _getMessageDetail(String email, String messageId) async{
    await GmailApi(httpClient).users.messages.get(email, messageId,
        format: "full").
    then((response){
      Message message = response;
      setState(() {
        messagesList.add(message);
        List<MessagePartHeader> header = message.payload.headers;
        print("MessageId : " + message.id);
        print("MessageFrom : " + header[0].name);
        print("Messagelable : " + message.labelIds[0]);
        print("MessageList : " + messagesList.length.toString());
      });
      print("Single message response : " + message.snippet);
    }).catchError((e){
      print("Single message Error: " + e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorAssets.themeColorBlue,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: ColorAssets.themeColorWhite,
          appBar: !isMessageSelected?
          AppBar(
            leading: GestureDetector(
              onTap: ()
              {

              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                width: 5.0,
                margin: EdgeInsets.only(left: 10.0),
                child: Image.asset(ImageAssets.menu_icon),
              ),
            ),
            actions: <Widget>[
              Container(
                height: 30.0,
                width: 30.0,
                margin: EdgeInsets.only(right: 11.0),
                child: CircleAvatar(
                  child: CachedNetworkImage(
                    imageUrl:
                    loggedInUserProfile,
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                             image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                    placeholder: (context, url) =>
                        CommonWidgets.getPlaceHolder(height: 30,width: 30),
                  ),
                ),
              )
            ],
            title: Text(
              StringAssets.inbox,
              style: appTitleStyle,
            ),
            centerTitle: true,
            backgroundColor: ColorAssets.themeColorBlue,
            elevation: 1.0,
          ):
          AppBar(
            backgroundColor: ColorAssets.themeColorBlue,
            leading: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: ()
                  {
                    isMessageSelected=!isMessageSelected;
                  },
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Icon(Icons.close,color: ColorAssets.themeColorWhite,)
                  ),
                ),
                Expanded(
                  child: Text(
                      "2",
                      style: countStyle
                  ),
                )

              ],
            ),
            actions: <Widget>[
              Container(
                padding: EdgeInsets.all(15.0),
                child: Image.asset(ImageAssets.delete,height: 15.0,width: 15.0,),
              ) ,Container(
                padding: EdgeInsets.all(15.0),
                child: Image.asset(ImageAssets.archive,height: 20.0,width: 20.0,),
              ), Container(
                padding: EdgeInsets.all(15.0),
                child: Image.asset(ImageAssets.mail,height: 20.0,width: 20.0,),
              ),
              Container(
              // margin: EdgeInsets.only(right:10.0,left: 10.0),
               margin: EdgeInsets.only(right:10.0,left: 8.0),
                padding: EdgeInsets.only(top:17.0,bottom: 17.0),
                child: Image.asset(ImageAssets.menu_dot,height: 20.0,width: 20.0,),
              )
            ],

          ),
          floatingActionButton: GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ComposeMailScreen(widget.googleSignInAccount)));
            },
            child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle
              ),
              child: Image.asset(ImageAssets.floating_button,fit: BoxFit.cover,),

            ),
          ),
          body: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                _buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    itemCount: messagesList != null ? messagesList.length : 0,
                      itemBuilder: (BuildContext context,int index)
                  {
                    return Container(
                      margin: EdgeInsets.only(top: index==0?5.0:0.0),
                      child: MessageRow(
                           isMessageSelected: isMessageSelected,
                            isStared: isStared,
                            message: messagesList[index],
                            position:index,
                            valueChanged: (value) {
                              if (value != null && value is String) {
                                if (value == "on_long_press") {
                                  setState(() {
                                    isMessageSelected=true;
                                  });
                                }
                                else if (value == "on_single_press") {
                                  if(isMessageSelected)
                                    {
                                      setState(() {
                                        isMessageSelected=false;
                                      });
                                    }
                                  else
                                    {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetails()));
                                    }

                                }
                                else if (value == "on_star_click") {
                                  setState(() {
                                    isStared=!isStared;
                                  });
                                }
                              }
                            }
                        ),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                  border: Border.all(color: ColorAssets.borderColor)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: "Search in Inbox",
                          hintStyle:searchHintStyle
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Icon(Icons.search,color: ColorAssets.themeColorGrey,),
                    )
                  ],
                ),
              );
  }
}