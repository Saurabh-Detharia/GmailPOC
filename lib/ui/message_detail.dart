import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';

class MessageDetails extends StatefulWidget {
  @override
  _MessageDetailsState createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {
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
                      Row(
                        children: <Widget>[
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
                                Text(
                                    "09:34 am - 1 hr ago",
                                    style:timeTextStyle
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                       Row(
                        children: <Widget>[
                            Container(
                              height: 30.0,
                              width: 30.0,
                              margin: EdgeInsets.only(right: 10.0),
                              padding: EdgeInsets.all(5.0),
                              child: Image.asset(ImageAssets.reply_icon),
                            ),
                          Container(
                            height: 30.0,
                            width: 30.0,
                            padding: EdgeInsets.all(5.0),
                            child: Image.asset(ImageAssets.star_inactive),
                            ),
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
                    margin: EdgeInsets.only(top: 15.0),
                    child: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(text:"How to create a great design",style: mailTitleStyle,),
                            WidgetSpan(
                                child:Container(
                                  margin: EdgeInsets.only(bottom: 2.0,left: 10.0),
                                  padding: EdgeInsets.only(top: 3.0,bottom: 3.0,right: 2.0,left: 3.0),
                                  color: ColorAssets.themeColorPurple,
                                  child: Text(StringAssets.primary,style: detailLabel),
                                )
                            ),
                          ],
                        )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum",style:timeTextStyle,),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    color: ColorAssets.themeColorGrey.withOpacity(0.3),
                    height: 1.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("2 Attachments",style: composeMailText,),
                        GestureDetector(
                          onTap: ()
                          {
                            
                          },
                          child: Container(
                            height: 30.0,
                              padding: EdgeInsets.all(6.0),
                              child: Image.asset(ImageAssets.down_arrow,)),
                        )
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 15.0),
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
                              Container(child: Text("Menu.pdf",style: bottomOptionStyle,))
                            ],
                          ) ,

                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10.0),
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
                                  child: Image.asset(ImageAssets.image_icon,height: 17.0,)),
                              Container(child: Text("logo.png",style:bottomOptionStyle ,))
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
          bottomNavigationBar:
          _buildBottomWidgets(context),
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
}
