import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:intl/intl.dart';
class MessageRowWeb extends StatefulWidget {
  final ValueChanged<dynamic> valueChanged;
  final bool isMessageSelected;
  final bool isStared;
  final int position;
  MessageRowWeb(
      {Key key,
        this.valueChanged,this.isMessageSelected,this.isStared,this.position})
      : super(key: key);
  @override
  _MessageRowWebState createState() => _MessageRowWebState();
}

class _MessageRowWebState extends State<MessageRowWeb> {
  bool isChecked=false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: ()
      {
       /* if (widget.valueChanged != null) {
          widget.valueChanged("on_long_press");
        }*/
       setState(() {
         isChecked=true;
       });
      },
      onTap: ()
      {
      /*  if (widget.valueChanged != null) {
          widget.valueChanged("on_single_press");
        }*/
      if(isChecked)
        {
          setState(() {
            isChecked=false;
          });
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal:10.0),
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
              Column(
                children: [
                  isChecked?
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(ImageAssets.message_selected,height: 30.0,width: 30.0,),
                  ):
                  CommonWidgets.getPlaceHolder(height: 28,width: 28),
                 GestureDetector(
                   onTap: ()
                   {
                    setState(() {
                      isChecked=!isChecked;
                    });
                   }
                   ,child: Container(
                     margin: EdgeInsets.only(top:5.0),
                     child: Icon(isChecked?Icons.check_box:Icons.check_box_outline_blank,color: ColorAssets.themeColorGrey,size: 15.0,)),
                 )

                ],
              )
/*                CachedNetworkImage(
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
                )*/,
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(height: 3.0,width: 3.0,margin: EdgeInsets.only(right: 5.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:ColorAssets.activeColor,
                              ),),
                            Text(
                                "Ashley Holand",
                                style: senderNameWeb
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 2.0,right: 2.0,top: 3.0,bottom: 3.0),
                              margin: EdgeInsets.only(left: 8.0),
                              color: widget.position%2==0?ColorAssets.themeColorPurple:ColorAssets.themeColorGreen,
                              child: Text(widget.position%2==0?StringAssets.primary:StringAssets.promotion,style: TextStyle(color: ColorAssets.themeColorWhite,fontSize: 5.0),),
                            )
                          ],
                        ),Container(
                          margin: EdgeInsets.only(top: 5.0),
                          child: Text(
                              "Tuesday update",
                              style: messageTitleStyleWeb
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5.0),
                          child: Text(
                              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard ",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: messageDesStyleWeb
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(DateFormat.jm().format(DateTime.now()),style: messageDesStyleWeb,),
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
}
