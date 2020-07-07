import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/commons/print_log.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:flutter_google_apis/ui/message_detail.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:intl/intl.dart';

import '../message_detail.dart';

class MessageRow extends StatefulWidget {
  final ValueChanged<dynamic> valueChanged;
  final int position;
  final Message message;
  bool isMessageSelected = false;
  bool isStared = false;


  final List<Attachment> attachmentList;
  MessageRow(
      {Key key,this.attachmentList,
          this.valueChanged,this.position, this.message})
      : super(key: key);
  @override
  _MessageRowState createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {

  String sender = "";
  String subject = "";
  String userProfile="";
  List<MessagePartHeader> headersList;

  @override
  void initState() {
    headersList = widget.message.payload.headers;
    _getSenderAndSubject();

    super.initState();
  }

  // This will used to get the subject and sender id
  _getSenderAndSubject(){
    for(MessagePartHeader header in headersList){
      if(header.name == "From"){
        setState(() {
          sender = header.value;
          userProfile= sender[0];

        });
      }if(header.name == "Subject"){
        setState(() {
          subject = header.value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // This will detect long tap to slect
      onLongPress: ()
      {
        setState(() {
          widget.isMessageSelected = !widget.isMessageSelected;
        });
        if (widget.valueChanged != null) {
          widget.valueChanged("on_long_press");
        }
      },

      // This will detect single tap to move to next screen
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetails(message: widget.message, isStared: widget.isStared,)));
        if (widget.valueChanged != null) {
          widget.valueChanged("on_single_press");
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.isMessageSelected?
                // This will used to show selection
               Container(
                 width: 40,
                 height: 40,
                 alignment: Alignment.center,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                 ),
                 child: Image.asset(ImageAssets.message_selected),
               ):
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            (widget.message.labelIds[0]== "UNREAD") ? Container(height: 5.0,width: 5.0,margin: EdgeInsets.only(right: 5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:ColorAssets.activeColor,
                            ),) : new Container(),
                            Flexible(
                              child: Text(
                                (sender.contains("<")) ?
                                sender.substring(0, sender.indexOf("<")) :
                                sender,
                                style: senderName,
                                maxLines: 1,
                              ),
                            ),
                            Container(
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
                              widget.message.labelIds[0] , style: TextStyle(color: ColorAssets.themeColorWhite,fontSize: 7.0),),
                            )
                          ],
                        ),Text(
                            subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: messageTitleStyle
                        ),
                        Text(
                            widget.message.snippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: messageDesStyle
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(formatTimestamp(int.parse(widget.message.internalDate)), style: messageDesStyle,),
                    GestureDetector(
                      // This will work for stare
                      onTap: ()
                      {
                        if (widget.valueChanged != null) {
                          widget.valueChanged("on_star_click");
                        }
                        setState(() {
                          widget.isStared = !widget.isStared;
                        });
                      },
                      child: Container(
                          width: 30.0,
                          height: 30.0,
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(widget.isStared?ImageAssets.star_active:ImageAssets.star_inactive,height: 15.0,width: 15.0,)),
                    )
                  ],
                ),
              ],
            ),
          ),
          new ListView.builder(
              shrinkWrap: true,
              itemCount: widget.attachmentList.length,
              itemBuilder:
                  (BuildContext context, int index) {
                return listItem(widget.attachmentList[index]);
              }),
          Container(
            color: ColorAssets.themeColorGrey.withOpacity(0.5),
            height: 1.0,
          )
        ],
      ),
    );
  }

  Widget listItem(Attachment list) {
    return InkWell(
      onTap: (){

      },
      child: Container(
        margin: EdgeInsets.only(right: 15.0, left: 15.0, top: 5.0, bottom: 20.0),
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

  // This will to format the date to display
  String formatTimestamp(int timestamp) {
    var format = new DateFormat('d MMM');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    if(date.day == new DateTime.now().day){
      format = new DateFormat('hh:mm a');
    }else{
      format = new DateFormat('d MMM');
    }
    return format.format(date);
  }}
