import 'dart:convert';

import 'package:flutter_access_refresh_token_manager_demo/api/api_exception.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic> decodeResponse(http.Response response) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException(response.statusCode, response.body);
  }
  return jsonDecode(response.body) as Map<String, dynamic>;
}
