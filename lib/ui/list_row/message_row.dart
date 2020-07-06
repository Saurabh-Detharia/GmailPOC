import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:intl/intl.dart';
class MessageRow extends StatefulWidget {
  final ValueChanged<dynamic> valueChanged;
  final bool isMessageSelected;
  final bool isStared;
  final int position;
  final Message message;
  MessageRow(
      {Key key,
          this.valueChanged,this.isMessageSelected,this.isStared,this.position, this.message})
      : super(key: key);
  @override
  _MessageRowState createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: ()
      {
        if (widget.valueChanged != null) {
          widget.valueChanged("on_long_press");
        }
      },
      onTap: ()
      {
        if (widget.valueChanged != null) {
          widget.valueChanged("on_single_press");
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
               widget.isMessageSelected?
               Container(
                 width: 40,
                 height: 40,
                 alignment: Alignment.center,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                 ),
                 child: Image.asset(ImageAssets.message_selected),
               ):
               CachedNetworkImage(
                  imageUrl:
                  "",
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorAssets.themeColorGrey,
                              width: 1.0),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                  placeholder: (context, url) =>
                      CommonWidgets.getPlaceHolder(height: 40,width: 40),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(height: 5.0,width: 5.0,margin: EdgeInsets.only(right: 5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:ColorAssets.activeColor,
                            ),),
                            Text(
                                widget.message.payload.headers[0].value.substring(0, widget.message.payload.headers[0].value.indexOf("<")),
                              style: senderName
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 2.0,right: 2.0,top: 3.0,bottom: 3.0),
                              margin: EdgeInsets.only(left: 8.0),
                              color: widget.position%2==0?ColorAssets.themeColorPurple:ColorAssets.themeColorGreen,
                              child: Text(widget.message.labelIds[0],style: TextStyle(color: ColorAssets.themeColorWhite,fontSize: 7.0),),
                            )
                          ],
                        ),Text(
                            widget.message.snippet,
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
                      onTap: ()
                      {
                        if (widget.valueChanged != null) {
                          widget.valueChanged("on_star_click");
                        }
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
          Container(
            color: ColorAssets.themeColorGrey.withOpacity(0.5),
            height: 1.0,
          )
        ],
      ),
    );
  }

  String formatTimestamp(int timestamp) {
    var format = new DateFormat('d MMM');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
//    if(date.day == new DateTime.now().day){
//      format = new DateFormat('hh:mm a');
//    }else{
//      format = new DateFormat('d MMM');
//    }
    return format.format(date);
  }}
