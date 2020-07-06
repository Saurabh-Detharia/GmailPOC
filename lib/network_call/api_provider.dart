import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_google_apis/gloabal/api_constants.dart';
import 'package:flutter_google_apis/network_call/custom_exception.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseUrl = "https://www.googleapis.com/gmail/v1/users/";

  Future<dynamic> get(url, accessToken) async {
    print("accessToken $accessToken");
    var responseJson;
    Map<String, String> header = {'Authorization': "Bearer $accessToken"};
    header['Accept'] = 'application/json';
    try {
      print("Final url: ${_baseUrl + url}");
      final response = await http.get(_baseUrl + url, headers: header);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(url, body, accessToken) async {
    var responseJson;
    Map<String, String> headers = {'Authorization': "Bearer $accessToken",
      'Accept' : "application/json"};
    try {
      final response =
          await http.post(_baseUrl + url, headers: headers, body: body);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
