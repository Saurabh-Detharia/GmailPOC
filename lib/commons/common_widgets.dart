import 'package:flutter/material.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';

class CommonWidgets
{

  static Widget getPlaceHolder({double height=40,double width=40}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: ColorAssets.themeColorGrey, width: 1.0),
      ),
      child: Image.asset(
        ImageAssets.profile_placeholder,
        width: width,
        height: height,
      ),
    );
  }
}