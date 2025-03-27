import 'dart:convert';

import 'package:http/http.dart' as http;

const String baseUrl = 'https://www.hrdesk.live/';

class BaseClient {
  var client = http.Client();

  //GET
  Future<dynamic> get(String api) async {
    var url = Uri.parse(api);
    print("Url11== $url");

    var headers = {
      //'Authorization': 'Bearer sfie328370428387=',
      'X-CMC_PRO_API_KEY': 'a89346d6-335c-45f1-81b0-b22e51e6fc0c'
    };

    var response = await client.get(url, headers: headers);
    print("Url11== ${response.statusCode}");
    print("Url11== ${response.body}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      //throw exception and catch it in UI
    }
  }

  Future<dynamic> post(String api, dynamic object) async { //, dynamic object
    var url = Uri.parse( baseUrl + api); //baseUrl
    print("Url== $url");
    String payload = json.encode(object);
    print("_payload== $payload");
    print("object== $object");

    var headers = {
      //'Authorization': 'Bearer sfie328370428387=',
      'Content-Type': 'multipart/form-data', //application/json
      //'api_key': 'ief873fj38uf38uf83u839898989',
      //"compcode":"${_payload}"

    };
    var request = http.MultipartRequest('POST', (url));
    request.headers.addAll(headers);
    request.fields['compcode'] = payload;

    var response = await request.send();


    //var response = await client.post(url,   body: _payload, headers: _headers);//body: _payload,
    print("Url== ${response.statusCode}");
   // print("Url== ${response.stream}");

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      print('Response data: $responseString');

      /*   var jsonResponse = json.decode(response.body);
      var webservicePath = jsonResponse['webservice_path'];
      var status = jsonResponse['status'];

      print('Webservice Path:===== $webservicePath');
      print('Status:===== $status');*/
      return responseString ;
    } else {
      //throw exception and catch it in UI
    }
  }

  ///PUT Request
  Future<dynamic> put(String api, dynamic object) async {
    var url = Uri.parse(baseUrl + api);
    var payload = json.encode(object);
    print("Url== $url");
    print("Url== $payload");

    var headers = {
      //'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksImVtYWlsX2lkIjoiYWppdG11bHNhbjRAZ21haWwuY29tIiwiaWF0IjoxNjg0MzAyNTk2LCJleHAiOjE2ODQzODg5OTZ9.0U2PykknfQ6PvF7oOBbxTy_ErXCcUTuwO_AmZ_6NbHE',
      'Content-Type': 'application/json',
     // 'api_key': 'ief873fj38uf38uf83u839898989',
    };

    var response = await client.put(url, body: payload, headers: headers);
    print("Url== ${response.statusCode}");
    print("Url== ${response.body}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      //throw exception and catch it in UI
    }
  }

  Future<dynamic> delete(String api) async {
    var url = Uri.parse(baseUrl + api);
    var headers = {
      'Authorization': 'Bearer sfie328370428387=',
    //  'api_key': 'ief873fj38uf38uf83u839898989',
    };

    var response = await client.delete(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      //throw exception and catch it in UI
    }
  }
}
