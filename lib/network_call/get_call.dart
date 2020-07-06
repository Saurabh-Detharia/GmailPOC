import 'package:http/http.dart' as http;
class HttpGetRequest
{
  static Map<String,String> headers;

   Future<String> callGetApi(Map<String, String> params, String uri) async{
    var response = await http.get(uri);
    return response.body;
  }

}