import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/models/google_user_profile.dart';
import 'package:flutter_google_apis/network_call/google_http_client.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/gmail_poc_icons_icons.dart';
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

import 'list_row/message_row_web.dart';

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
  bool isStared=false;
  String loggedInUserName="";
  String loggedInUserProfile="";
  bool isRowSelected=false; //for selecting list row
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
    if(!kIsWeb)
    {
      return  _buildMobileUi(context);
    }
    else
    {
      return buildWebUi();
    }
  }

  Widget buildWebUi() {
    return Scaffold(
      body: Container(
        child: Row(
          children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: ColorAssets.themeColorBlue,
                  child: Column(
                    children: [

                    ],
                  ),
                ),
              ),
            Expanded(
              flex:2,
              child: Container(
                color: ColorAssets.themeColorWhite,
                child: Column(
                  children: [
                    _buildSearchBarForWeb(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (BuildContext context,int index)
                          {
                            return Container(
                              margin: EdgeInsets.only(top: index==0?5.0:0.0),
                              child: MessageRowWeb(
                                  isMessageSelected: isMessageSelected,
                                  isStared: isStared,
                                  position:index,
                                  valueChanged: (value) {
                                    if (value != null && value is String) {
                                      if (value == "on_long_press") {
                                        /*  setState(() {
                                            isMessageSelected=true;
                                          });*/
                                      }
                                      else if (value == "on_single_press") {
                                        if(isMessageSelected)
                                        {
                                          setState(() {
                                            isRowSelected=true;
                                          });
                                        }
                                        else
                                        {
                                          //   Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetails()));
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
                    ),
                  ],
                )

                ,
              ),
            ),
            Container(
                width: 1,
                color: Colors.grey),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(15.0),
                color: ColorAssets.themeColorWhite,
                child: Container(
                  child:  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              CommonWidgets.getPlaceHolder(height: 40,width: 40),
                              Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    RichText(
                                        text: TextSpan(
                                          style: msgDetailSender,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:"Ashley Holand",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'sf_light',
                                              ),
                                            ),TextSpan(
                                                text:"  to  ",
                                                style: writeMailStyle
                                            ),
                                            TextSpan(
                                                text:"Me",
                                                style: msgDetailSender
                                            ),
                                          ],
                                        )) ,
                                    Container(
                                      margin: EdgeInsets.only(top: 5.0),
                                      child: Text(
                                          "09:34 am - 1 hr ago",
                                          style:timeTextStyleWeb
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Image.asset(ImageAssets.delete,color:ColorAssets.themeColorBlue,height: 15.0,width: 15.0,),
                              ) ,Container(
                                padding: EdgeInsets.all(10.0),
                                child: Image.asset(ImageAssets.archive,color:ColorAssets.themeColorBlue,height: 15.0,width: 15.0,),
                              ), Container(
                                padding: EdgeInsets.all(10.0),
                                child: Image.asset(ImageAssets.mail,color:ColorAssets.themeColorBlue,height: 15.0,width: 15.0,),
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Image.asset(ImageAssets.reply_icon,color:ColorAssets.themeColorBlue,height: 15.0,width: 15.0,),
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Image.asset(ImageAssets.star_active,height: 15.0,width: 15.0,),
                              ),
                              Container(
                                margin: EdgeInsets.only(right:10.0,left: 8.0),
                                padding: EdgeInsets.only(top:17.0,bottom: 17.0),
                                child: Image.asset(ImageAssets.menu_dot,color:ColorAssets.themeColorBlue,height: 15.0,width: 15.0,),
                              )
                            ],
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15.0),
                        height: 1.0,
                        color: ColorAssets.themeColorGrey.withOpacity(0.3),
                      ),
                      Container(
                        margin: EdgeInsets.only(top:10.0),
                        child: Row(
                          children: [
                            Text("How to create a great design",style: mailTitleStyleWeb,),
                            Container(
                              margin: EdgeInsets.only(bottom: 2.0,left: 10.0),
                              padding: EdgeInsets.only(top: 3.0,bottom: 3.0,right: 2.0,left: 3.0),
                              color: ColorAssets.themeColorPurple,
                              child: Text(StringAssets.primary,style: detailLabel),
                            ),


                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15.0),
                        child: Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum",style:timeTextStyleWeb,),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        color: ColorAssets.themeColorGrey.withOpacity(0.3),
                        height: 1.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("2 Attachments",style: composeMailTextWeb,),
                            GestureDetector(
                              onTap: ()
                              {

                              },
                              child: Container(
                                  height: 25.0,
                                  padding: EdgeInsets.all(6.0),
                                  child: Image.asset(ImageAssets.down_arrow,)),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 15.0,left: 15.0,top: 5.0,bottom: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                              ),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(right: 5.0),
                                      child: Image.asset(ImageAssets.pdf_icon,height: 17.0,)),
                                  Container(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Menu.pdf",style: timeTextStyleWeb,),
                                      Text("10.04 MB",style: sizeStyleWeb,),
                                    ],
                                  ))
                                ],
                              ) ,

                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(right: 15.0,left: 15.0,bottom: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                              ),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(right: 5.0,top: 5.0,bottom: 5.0),
                                      child: Image.asset(ImageAssets.image_icon,height: 17.0,)),
                                  Container(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("logo.png",style:bottomOptionStyle ,),
                                      Text("2 MB",style: sizeStyleWeb,),

                                    ],
                                  ))
                                ],
                              ) ,

                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom:  15.0,top: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 12.0,left: 12.0,top: 7.0,bottom: 7.0),
                              margin: EdgeInsets.only(right: 5.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                              ),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      width: 30.0,
                                      child: Image.asset(ImageAssets.reply_icon,height: 12.0,)),
                                  Container(child: Text(StringAssets.reply,style: bottomOptionStyleWeb,))
                                ],
                              ) ,

                            ),
                            Container(
                              margin: EdgeInsets.only(right: 5.0),
                              padding: EdgeInsets.only(right: 12.0,left: 12.0,top: 7.0,bottom: 7.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                              ),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      width: 30.0,
                                      child: Image.asset(ImageAssets.reply_all,height: 12.0,)),
                                  Container(child: Text(StringAssets.replyAll,style:bottomOptionStyleWeb ,))
                                ],
                              ) ,

                            ),
                            Container(
                              padding: EdgeInsets.only(right: 12.0,left: 12.0,top: 7.0,bottom: 7.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                              ),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      width: 30.0,
                                      child: Image.asset(ImageAssets.forward,height: 12.0,)),
                                  Container(child: Text(StringAssets.forward,style: bottomOptionStyleWeb,))
                                ],
                              ) ,

                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMobileUi(BuildContext context) {
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

  Widget _buildSearchBarForWeb() {
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
          GestureDetector(
            child: Icon(Icons.search,color: ColorAssets.themeColorGrey),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                  hintText: "Search in Inbox",
                  hintStyle:searchHintStyle
              ),
            ),
          ),
        ],
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