import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/commons/print_log.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/network_call/google_http_client.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:flutter_google_apis/ui/reply.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageDetails extends StatefulWidget {

  final Message message;
  bool isStared;
  final Color color;

  MessageDetails({this.message, this.isStared,this.color});

  @override
  _MessageDetailsState createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {

  String sender = "";
  String subject = "";
  List<MessagePartHeader> headersList;
  String userProfile="";
  SharedPreferences sharedPreference;
  String loggedInUserName = "",loggedInUserEmail = "";
  bool isExpanded=false;

  Message msg;

  GoogleHttpClient httpClient;

  List<MessagePart> attachment = [];
  List<Attachment> attachmentList = [];
  String email;

  List _parts = new List();

  MessagePart messagePart;

  @override
  void initState() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      this.sharedPreference = sharedPreferences;
      if (sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
        if (mounted &&
            sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
          setState(() {
            loggedInUserEmail = sharedPreferences.getString(ApiConstants.loggedInUserMail);
            email = sharedPreference.get(ApiConstants.loggedInUserMail);
          });
        }
      }
    });
    headersList = widget.message.payload.headers;
    msg = widget.message;
    _getAttachment(msg);
    //attachment = widget.message.payload.parts;
    print('attachment : ' + attachment.length.toString());
    _getSenderAndSubject();
     super.initState();
  }

  _getAttachment(Message msg) {
    List<MessagePart> parts = msg.payload.parts;
    for (var i = 0; i < parts.length; i++) {
      MessagePart part = parts[i];
      String fileName = parts[i].filename;
      messagePart = parts[i];
      //print('files : ' + parts[i].body.attachmentId);
      String mimeType = mime(fileName);
      if (mimeType != null) {
        if (mimeType.contains('text/plain')) {
          attachmentList.add(Attachment(fileName, mimeType));
        } else if (mimeType.contains('image')) {
          attachmentList.add(Attachment(fileName, mimeType));
        }
      }
//      MessagePartBody attachPart = GmailApi(httpClient).users.messages.attachments.
//      get(email, msg.id, parts[i].body.attachmentId).execute();
      if (fileName != "") {
        attachment.add(part);
      }
    }
  }

  _getSenderAndSubject() {
    for (MessagePartHeader header in headersList) {
      if (header.name == "From") {
        setState(() {
          sender = header.value;
          userProfile=sender[0];
        });
      }
      if (header.name == "Subject") {
        setState(() {
          subject = header.value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorAssets.themeColorBlue,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: ColorAssets.themeColorWhite,
        appBar: AppBar(
          backgroundColor: ColorAssets.themeColorBlue,
          leading: Row(
            children: <Widget>[
              GestureDetector(
                onTap: ()
                {
                  Navigator.pop(context);
                },
                child: Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
                    child: Icon(Icons.arrow_back,color: ColorAssets.themeColorWhite,)
                ),
              ),

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
              child: Image.asset(ImageAssets.mail_open,height: 20.0,width: 20.0,),
            ),
            Container(
              margin: EdgeInsets.only(right:10.0,left: 8.0),
              padding: EdgeInsets.only(top:17.0,bottom: 17.0),
              child: Image.asset(ImageAssets.menu_dot,height: 20.0,width: 20.0,),
            )
          ],

        ),
          body: Container(
            padding: EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorAssets.themeColorBlue
                              ),
                              child: Text(userProfile,style: TextStyle(fontSize: 20.0,fontWeight:FontWeight.w500,color: Colors.white ),),

                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    RichText(
                                        text: TextSpan(
                                          style: msgDetailSender,
                                          children: <TextSpan>[
                                            TextSpan(
                                              //text:"HR Manager - Bacancy Technology",
                                              text: (sender.contains("<")) ?sender.substring(0, sender.indexOf("<")) : sender,
                                              style:msgDetailSender

                                            ),TextSpan(
                                                text:"  to  ",
                                                style: writeMailStyle
                                            ),
                                            TextSpan(
                                                text:"Me",
                                                style: msgDetailSender
                                            ),
                                          ],
                                        ),
                                    overflow: TextOverflow.ellipsis,) ,
                                    Row(
                                      children: [
                                        Text(
                                            formatTimestamp(int.parse(widget.message.internalDate)),
                                            style:timeTextStyle
                                        ),
                                        GestureDetector(
                                          onTap: ()
                                          {
                                            setState(() {
                                              isExpanded=!isExpanded;
                                            });
                                          },
                                          child: Icon(Icons.arrow_drop_down,color: ColorAssets.greyText,),
                                        )
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                       Row(
                        children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReplyScreen(subject, widget.message, sender)));
                              },
                              child: Container(
                                height: 30.0,
                                width: 30.0,
                                margin: EdgeInsets.only(right: 10.0),
                                padding: EdgeInsets.all(5.0),
                                child: Image.asset(ImageAssets.reply_icon),
                              ),
                            ),
                          InkResponse(
                            onTap: () {
                              setState(() {
                                widget.isStared = !widget.isStared;
                              });
                            },
                            child: Container(
                              height: 30.0,
                              width: 30.0,
                              padding: EdgeInsets.all(5.0),
                              child: Image.asset((widget.isStared)
                                  ? ImageAssets.star_active
                                  : ImageAssets.star_inactive),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  Visibility(
                    visible: isExpanded,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.only(top:10.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3)),
                          borderRadius: BorderRadius.all(Radius.circular(5))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("To :- $loggedInUserEmail",style: timeTextStyle,),
                          Text("From :- ${sender.contains("<") ?sender.substring(0, sender.indexOf("<")) : sender}",style: timeTextStyle,),
                          Text("Date :- ${formatDate(int.parse(widget.message.internalDate))} , ${formatTimestamp(int.parse(widget.message.internalDate))}",style: timeTextStyle,),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    height: 1.0,
                    color: ColorAssets.themeColorGrey.withOpacity(0.3),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 15.0),
                    child: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(text:subject,style: mailTitleStyle,),
                            WidgetSpan(
                                child:Container(
                                  padding: EdgeInsets.all(4.0),
                                  margin: EdgeInsets.only(left: 8.0),
                                  color: (widget.message.labelIds[0]== "PRIMARY") ? ColorAssets.themeColorPurple:
                                  (widget.message.labelIds[0]== "CATEGORY_PROMOTIONS") ? ColorAssets.themeColorGreen :
                                  (widget.message.labelIds[0]== "CATEGORY_SOCIAL") ? ColorAssets.themeColorRed :
                                  (widget.message.labelIds[0]== "IMPORTANT") ? Colors.amberAccent :
                                  (widget.message.labelIds[0]== "UNREAD") ? Colors.blue :
                                  (widget.message.labelIds[0]== "CATEGORY_UPDATES") ? Colors.orangeAccent :
                                  (widget.message.labelIds[0]== "CATEGORY_PERSONAL") ? Colors.pinkAccent :
                                  ColorAssets.themeColorBlack,
                                  child: Text((widget.message.labelIds[0] == "CATEGORY_PROMOTIONS") ? "PROMOTIONS" :
                                  (widget.message.labelIds[0] == "CATEGORY_SOCIAL") ? "SOCIAL" :
                                  (widget.message.labelIds[0] == "CATEGORY_UPDATES") ? "UPDATES" :
                                  (widget.message.labelIds[0] == "CATEGORY_PERSONAL") ? "PERSONAL" :
                                  widget.message.labelIds[0] , style: detailLabel),
                                )
                            ),
                          ],
                        )
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 15.0),
                    child: Text(widget.message.snippet,
                      style:timeTextStyle,),


                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    color: ColorAssets.themeColorGrey.withOpacity(0.3),
                    height: 1.0,
                  ),
                  attachment.length > 0
                      ? Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 20.0),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      attachment.length.toString() +
                                          " Attachment",
                                      style: composeMailText,
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                          height: 30.0,
                                          padding: EdgeInsets.all(6.0),
                                          child: Image.asset(
                                            ImageAssets.down_arrow,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              new ListView.builder(
                                shrinkWrap: true,
                                  itemCount: attachmentList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return listItem(attachmentList[index]);
                                  })

                              /*Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                          right: 15.0,
                                          left: 15.0,
                                          top: 5.0,
                                          bottom: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          border: Border.all(
                                              color: ColorAssets.themeColorGrey
                                                  .withOpacity(0.3))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              margin:
                                                  EdgeInsets.only(right: 5.0),
                                              child: Image.asset(
                                                ImageAssets.pdf_icon,
                                                height: 17.0,
                                              )),
                                          Container(
                                              child: Text(
                                            "Menu.pdf",
                                            style: bottomOptionStyle,
                                          ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      padding: EdgeInsets.only(
                                          right: 15.0,
                                          left: 15.0,
                                          top: 5.0,
                                          bottom: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          border: Border.all(
                                              color: ColorAssets.themeColorGrey
                                                  .withOpacity(0.3))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              margin:
                                                  EdgeInsets.only(right: 5.0),
                                              child: Image.asset(
                                                ImageAssets.image_icon,
                                                height: 17.0,
                                              )),
                                          Container(
                                              child: Text(
                                            "logo.png",
                                            style: bottomOptionStyle,
                                          ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )*/
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomWidgets(context),
        ),
      ),
    );
  }

  Widget listItem(Attachment list) {
    return InkWell(
      onTap: (){

      },
      child: Container(
        margin: EdgeInsets.only(right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
        padding: EdgeInsets.only(right: 15.0, left: 15.0, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            border:
                Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Image.asset(
                  list.mimeType.contains('text/plain')
                      ? ImageAssets.pdf_icon
                      : ImageAssets.image_icon,
                  height: 17.0,
                )),
            Container(
                child: Text(
              list.fileName,
              style: bottomOptionStyle,
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidgets(BuildContext context) {
    return BottomAppBar(
          elevation: 0.0,
          child: Container(
            margin: EdgeInsets.only(bottom:  15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width/3.5,
                  padding: EdgeInsets.only(right: 12.0,left: 12.0,top: 10.0,bottom: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 5.0),
                          child: Image.asset(ImageAssets.reply_icon,height: 17.0,)),
                      Container(child: Text(StringAssets.reply,style: bottomOptionStyle,))
                    ],
                  ) ,

                ),
                Container(
                  width: MediaQuery.of(context).size.width/3.5,
                  padding: EdgeInsets.only(right: 12.0,left: 12.0,top: 10.0,bottom: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 5.0),
                          child: Image.asset(ImageAssets.reply_all,height: 17.0,)),
                      Container(child: Text(StringAssets.replyAll,style:bottomOptionStyle ,))
                    ],
                  ) ,

                ),
                Container(
                  width: MediaQuery.of(context).size.width/3.5,
                  padding: EdgeInsets.only(right: 12.0,left: 12.0,top: 10.0,bottom: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    border: Border.all(color: ColorAssets.themeColorGrey.withOpacity(0.3))
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 5.0),
                          child: Image.asset(ImageAssets.forward,height: 17.0,)),
                      Container(child: Text(StringAssets.forward,style: bottomOptionStyle,))
                    ],
                  ) ,

                ),
              ],
            ),
          ),
        );
  }

  String formatTimestamp(int timestamp) {
    var format = new DateFormat('d MMM');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    if(date.day == new DateTime.now().day){
      format = new DateFormat('hh:mm a');
    }else{
      format = new DateFormat('d MMM');
    }
    return format.format(date);
  }
  String formatDate(int timestamp) {
    var format = new DateFormat('dd MMM yyyy');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format.format(date);
  }
}

class Attachment {
  String fileName;
  String mimeType;

  Attachment(this.fileName, this.mimeType);
}
