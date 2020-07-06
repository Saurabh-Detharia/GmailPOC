import 'dart:async';
import 'dart:convert';
import 'package:flutter_google_apis/network_call/api_provider.dart';
import 'package:http/http.dart' as http;

//Base api service

class ApiServices {
  ApiProvider _provider = ApiProvider();

  ///  3. send email

  Future<Null> testingEmail(String userId, Map header, String sub, String msg, String receiver) async {
    header['Accept'] = 'application/json';
    header['Content-type'] = 'application/json';

    var from = userId;
    var to = receiver;
    var subject = sub;
    //var message = 'worked!!!';
    var message = msg;
    var content = '''
    Content-Type: text/html; charset="us-ascii"
    MIME-Version: 1.0
    Content-Transfer-Encoding: 7bit
    to: ${to}
    from: ${from}
    subject: ${subject}
    ${message}''';

    var bytes = utf8.encode(content);
    var base64 = base64Encode(bytes);
    var body = json.encode({'raw': base64});

    String url = 'https://www.googleapis.com/gmail/v1/users/' + userId + '/messages/send';

    final http.Response response =
        await http.post(url, headers: header, body: body);
    if (response.statusCode != 200) {
      print('error: ' + response.statusCode.toString());
      print(url);
      print(json.decode(response.body));
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    print('ok: ' + response.statusCode.toString());
    print(data);
  }
}
