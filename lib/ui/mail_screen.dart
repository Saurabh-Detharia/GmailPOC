import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_apis/commons/common_widgets.dart';
import 'package:flutter_google_apis/commons/print_log.dart';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/models/google_user_profile.dart';
import 'package:flutter_google_apis/network_call/google_http_client.dart';
import 'package:flutter_google_apis/styles/color_assets.dart';
import 'package:flutter_google_apis/styles/image_assests.dart';
import 'package:flutter_google_apis/styles/string_assets.dart';
import 'package:flutter_google_apis/styles/widget_styles.dart';
import 'package:flutter_google_apis/ui/compose_mail.dart';
import 'package:flutter_google_apis/ui/list_row/message_row.dart';
import 'package:flutter_google_apis/ui/login_screen.dart';
import 'package:flutter_google_apis/ui/message_detail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MailsScreen extends StatefulWidget {

  MailsScreen();

  @override
  _MailsScreenState createState() => _MailsScreenState();

}

class _MailsScreenState extends State<MailsScreen> {

  GoogleHttpClient httpClient;
  ListMessagesResponse listMessagesResponse;
  List<Message> messagesList = [];
  List<Attachment> attachmentList = [];
  List<Message> sortedMessagesList = [];
  List<Message> _searchResult = [];
  bool isMessageSelected=false,isStared = false, isLoading = true;
  SharedPreferences sharedPreference;
  String loggedInUserName = "", loggedInUserProfile = "",loggedInUserEmail = "",nextPageToken = "";
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textEditingController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPreferences) {
      this.sharedPreference = sharedPreferences;

      // This checks the user is logged in or not
      if (sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
        if (mounted &&
            sharedPreference.getBool(ApiConstants.IS_USER_LOGGED_IN) != null) {
          setState(() {
            loggedInUserProfile =
                sharedPreferences.getString(ApiConstants.loggedInUserProfile);
            loggedInUserEmail =
                sharedPreferences.getString(ApiConstants.loggedInUserMail);

            var res = jsonDecode(
                sharedPreferences.getString(ApiConstants.authHeaders));

            Map<String, String> headers = new Map();
            for (int k = 0; k < res.length; k++) {
              headers["Authorization"] = res["Authorization"];
              headers["X-Goog-AuthUser"] = res["X-Goog-AuthUser"];
            }

            getAuthHeaders(headers);
          });
        }
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if(nextPageToken != null) {
          setState(() {
            isLoading = true;
          });
          _callNextPageMessageListApi(loggedInUserEmail);
        }
      }
    });
  }

//  calling messageList api
  getAuthHeaders(Map<String, String> headers) async{
    httpClient = GoogleHttpClient(headers);
    setState(() {
      isLoading = true;
    });
    _callMessageListApi(loggedInUserEmail);
  }

  _callMessageListApi(String email) async {
    await GmailApi(httpClient)
        .users
        .messages
        .list(
          email,
        )
        .then((response) {
      if (response != null) {
        listMessagesResponse = response;
        nextPageToken = response.nextPageToken;
        sortedMessagesList.clear();
        getFullMessageDetails();
      }
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
      print("Message List Api Error: " + e.toString());
    });
  }

//  MessageList api for next page
  _callNextPageMessageListApi(String email) async {
    setState(() {
      isLoading = true;
    });
    await GmailApi(httpClient).users.messages.list(email, pageToken: nextPageToken).then((response){
      if(response != null){
        listMessagesResponse = response;
        nextPageToken = response.nextPageToken;
        sortedMessagesList.clear();
        getFullMessageDetails();
      }
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
      print("Message List Api Error: " + e.toString());
    });
  }

//  message detail api for every mails
  void getFullMessageDetails() async {
    listMessagesResponse.messages.forEach((message) async {
     await _getMessageDetail(sharedPreference.get(ApiConstants.loggedInUserMail), message.id);
     if(sortedMessagesList.length == listMessagesResponse.messages.length) {
       if(messagesList.length < 20 && nextPageToken != ""){
         _callNextPageMessageListApi(loggedInUserEmail);
       }
       _sortedList();
     }
    });
  }

  void getFullMessageDetailsForNextPage() async {
    listMessagesResponse.messages.forEach((message) async {
      await _getMessageDetail(sharedPreference.get(ApiConstants.loggedInUserMail), message.id);
      if(sortedMessagesList.length == listMessagesResponse.messages.length) {
        _sortedList();
      }
    });
  }

  _sortedList(){
    setState(() {
      messagesList.sort((a,b) {
        var adate = a.internalDate;
        var bdate = b.internalDate;
        return bdate.compareTo(adate);
      });
      isLoading = false;
    });
  }

  _getMessageDetail(String email, String messageId) async {
    await GmailApi(httpClient)
        .users
        .messages
        .get(email, messageId, format: "full")
        .then((response) {
      Message message = response;
      setState(() {
        sortedMessagesList.add(message);
        if(message.labelIds[0] != "CHAT" && message.labelIds[0] != "SENT" && message.labelIds[0] != "DRAFT")
          messagesList.add(message);
        List<MessagePartHeader> header = message.payload.headers;

      _getAttachment(message);
      });
    }).catchError((e){
      printLog("Single message Error: " + e.toString());
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
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(10.0),
                width: 5.0,
                margin: EdgeInsets.only(left: 10.0),
                child: Image.asset(ImageAssets.menu_icon),
              ),
            ),
            actions: <Widget>[
                InkWell(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    signOutWithGoogle();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Container(
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
                  ),
                ),
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
                  onTap: () {
                    setState(() {
                      isMessageSelected=!isMessageSelected;
                    });
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => ComposeMailScreen()));
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
          body:
          Stack(
            children: [
               (messagesList.length != 0)? Container(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    _buildSearchBar(),
                    Expanded(
                      child:
                      _searchResult.length != 0 || _textEditingController.text.isNotEmpty
                          ?
                      ListView.builder(
                          itemCount: _searchResult != null ? _searchResult.length : 0,
                          itemBuilder: (BuildContext context,int index){
                            return Container(
                              margin: EdgeInsets.only(top: index==0?5.0:0.0),
                              child: MessageRow(
                                attachmentList: attachmentList,
                                position: index,
                                message: _searchResult[index],
                              ),
                            );
                          })


                     : (messagesList.length != 0) ? RefreshIndicator(
                        onRefresh: (){return _callMessageListApi(loggedInUserEmail);},
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messagesList != null ? messagesList.length : 0,
                            itemBuilder: (BuildContext context,int index){
                          return Container(
                            margin: EdgeInsets.only(top: index==0?5.0:0.0),
                            child: MessageRow(
                              attachmentList: attachmentList,
                            position: index,
                            message: messagesList[index],
                          ));
                        }),
                      )
                      : Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber))),
                    )
                  ],
                ),
              )
              : !isLoading ? Container( color: Colors.white,alignment: Alignment.center,child: Text("No emails found!", style: TextStyle(color: Colors.grey, fontSize: 32),)): new Container()
              ,isLoading ? Center(child: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber))) : new Container()
            ],
          ),
        ),
      ),
    );
  }

  _getAttachment(Message msg) {
    attachmentList.clear();
    List<MessagePart> parts = msg.payload.parts;
    for (var i = 0; i < parts.length; i++) {
      MessagePart part = parts[i];
      String fileName = parts[i].filename;
      //messagePart = parts[i];
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
//      if (fileName != "") {
//        attachment.add(part);
//      }
    }
  }


  // This is search box
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
                        controller: _textEditingController,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration.collapsed(
                          hintText: "Search in Inbox",
                          hintStyle:searchHintStyle,
                        ),
                      ),
                    ),
                    _textEditingController.text.isNotEmpty ? GestureDetector(
                      onTap: (){
                        _textEditingController.clear();
                        onSearchTextChanged('');
                      },
                      child: Icon(Icons.close,color: ColorAssets.themeColorGrey,),
                    ) : GestureDetector(
                      onTap: (){
                        onSearchTextChanged('');
                      },
                      child: Icon(Icons.search,color: ColorAssets.themeColorGrey,),
                    )
                  ],
                ),
              );
  }

//  silent login for getting user to sign out
  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount currentUser = _googleSignIn.currentUser;
    if (currentUser == null) {
      currentUser = await _googleSignIn.signInSilently();
    }
    if (currentUser == null) {
      currentUser = await _googleSignIn.signIn();
    }
    final GoogleSignInAuthentication googleAuth =
    await currentUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    return user;
  }

  // This will used to sign out
  Future<Null> signOutWithGoogle() async {
    signInWithGoogle();
    await firebaseAuth.signOut();
    await _googleSignIn.signOut();
    sharedPreference.clear();
    setState(() {
      isLoading = false;
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    messagesList.forEach((message) {
      String sender, subject;
      for(MessagePartHeader header in message.payload.headers){
        if(header.name == "From"){
          setState(() {
            sender = header.value;
          });
        }if(header.name == "Subject"){
          setState(() {
            subject = header.value;
          });
        }
      }
      if (sender.toLowerCase().contains(_textEditingController.text.toLowerCase()) || subject.toLowerCase().contains(_textEditingController.text.toLowerCase()))
        _searchResult.add(message);
    });
    setState(() {});
  }

}