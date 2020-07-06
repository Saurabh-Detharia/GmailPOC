import 'package:flutter/material.dart';
import 'package:flutter_google_apis/models/google_user_profile.dart';
import 'package:flutter_google_apis/network_call/google_http_client.dart';
import 'package:googleapis/gmail/v1.dart' show GmailApi, ListMessagesResponse, ListThreadsResponse, Message, MessagePartHeader, Thread;

class MailsScreen extends StatefulWidget {

  String accessToken;
   GoogleUserProfile googleUserProfile;
//  GoogleSignIn googleSignIn;

  MailsScreen({this.googleUserProfile});

  @override
  _MailsScreenState createState() => _MailsScreenState();
}

class _MailsScreenState extends State<MailsScreen> {

  Map<String, String> authHeaders;
  GoogleHttpClient httpClient;
  ListMessagesResponse listMessagesResponse;
  ListThreadsResponse listThreadsResponse;
  List<Message> messagesList = [];
  List<Thread> threadsList = [];

  @override
  void initState() {
    print("in okkk");
    getAuthHeaders();
    super.initState();
  }

  getAuthHeaders() async{
    authHeaders = await widget.googleUserProfile.authHeaders;
    httpClient = GoogleHttpClient(authHeaders);
    _callMessageListApi(widget.googleUserProfile.email);
//    _callThreadsListApi(widget.googleUserProfile.email);
//    _getFullMessageThread(widget.googleUserProfile.email, "17312defa7af6731");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.blue[100]),
    );
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

  _callThreadsListApi(String email) async {
    await GmailApi(httpClient).users.threads.list(
      email,
    ).then((response){
      if(response != null){
        listThreadsResponse = response;
        print("Threads List Api Response: " + listThreadsResponse.toString());
        getFullThreadsDetails();
      }
    }).catchError((e){
      print("Threads List Api Error: " + e.toString());
    });
  }

  _getFullMessageThread(String email, String threadId) async{
    await GmailApi(httpClient).users.threads.get(email, threadId).
    then((response){
      Thread thread = response;
      setState(() {
        threadsList.add(thread);
        print("ThreadId : " + thread.snippet);
        print("ThreadList : " + messagesList.length.toString());
      });
      print("Single thread response : " + thread.snippet);
    }).catchError((e){
      print("Single thread Error: " + e.toString());
    });
  }

  void getFullMessageDetails() {
    listMessagesResponse.messages.forEach((message) async {
     await _getMessageDetail(widget.googleUserProfile.email, message.id);
    });
  }

  void getFullThreadsDetails() {
    listThreadsResponse.threads.forEach((thread) async {
      await _getFullMessageThread(widget.googleUserProfile.email, thread.id);
    });
  }
}