import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';


class AlertMessages
{
  Function onclick;
  AlertMessages({this.onclick});
  void showAlert(String msg,GlobalKey<ScaffoldState> scaffoldKey)
  {
    final snackBar = SnackBar(
      duration: Duration(
          seconds: 2
      ),
      content: Text(msg),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void showDialogAlert(BuildContext context,String msg,{FocusNode focusField}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              actions: <Widget>[
                GestureDetector(
                  onTap: (
                  onclick()
                  ),
                )
              ],

          );
        });
  }

  showDialogAlertWithOption(bool isCameraPermission,BuildContext context,String msg) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: MediaQuery.of(context).size.width / 1.3,
              // height:160.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0,horizontal: 5.0),
                    child: Text(msg)
                  ),
                  Container(
                    child: Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            StringAssets.cancel,
                            textAlign: TextAlign.center,
                          ),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(StringAssets.yes
                        ),
                      )
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

