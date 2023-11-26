import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_app/model/access_token.dart';
import 'package:iot_app/provider/log_provider.dart';

class TokenProvider {
  TokenProvider._();

  static Future<String?> getToken(String ipAddress) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://$ipAddress/auth/realms/master/protocol/openid-connect/token'));
    request.bodyFields = {
      'grant_type': 'client_credentials',
      'client_id': 'quy',
      'client_secret': 'JdH6fLtpmYCj62XAHbUfdxeaAgl9tjyX'
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    Log.print("data--> ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      Map<String, dynamic> jsonMap = json.decode(data);
      AccessToken accessToken = AccessToken.fromJson(jsonMap);
      return accessToken.accessToken;
    } else {
      Log.print("response--> ${response.reasonPhrase}");
      return null;
    }
  }
}
