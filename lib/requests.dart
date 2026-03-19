import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

Future<dynamic> fetchWithHeaders(String url) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_response_$url') ?? "null";
    final lastFetch = prefs.getInt('last_fetch_time_$url') ?? 0;
    bool isOffline = !(await hasNetworkConnection());
    
    if (isOffline || (cachedData != "null" && DateTime.now().millisecondsSinceEpoch - lastFetch < 300000)) {
      log("Use cached data for $url");
      return jsonDecode(cachedData); // Use cached data
    }

    // Get bearer token if available (prefer secure storage)
    final token = await _getBearerToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 429) {
      final dynamic responseData = jsonDecode(response.body);
      await prefs.setString('cached_response_$url', response.body);
      await prefs.setInt('last_fetch_time_$url', DateTime.now().millisecondsSinceEpoch);
      return responseData;
    } else if (response.statusCode == 418) {
      throw Exception('🔥 Boosters Désactivées.');
    } else if (response.statusCode == 499) {
      final dynamic responseData = jsonDecode(response.body);
      final int timestamp = responseData["timestamp"];
      await prefs.setInt('next_booster', timestamp);
      throw Exception('🔥 Timer non syncronisé...');
    } else if (response.statusCode == 500) {
      throw Exception('💣 Super erreur du serveur. Réessayez plus tard !');
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  } catch (e) {
    // Handle errors
    print('Error occurred: $e');
    final errorMessage = e.toString().replaceFirst('Exception: ', '');
    throw Exception(errorMessage);
  }
}

Future<bool> hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

/// Sends a POST request to create a new plate on the server.
/// Expects the server to accept JSON with keys: name, date (yyyy-MM-dd), moment, personCount, tools
Future<dynamic> sendPlate({
  required String name,
  required DateTime date,
  required String moment,
  required int personCount,
  required List<String> tools,
}) async {
  final url = '${Config.apiBaseUrl}/plates/';
  final body = {
    'name': name,
    'date': DateFormat('yyyy-MM-dd').format(date),
    'moment': moment,
    'personCount': personCount,
    'tools': tools,
  };

  // Use postWithHeaders which will attach Bearer token when available
  return await postWithHeaders(url, body);
}

final _secureStorage = const FlutterSecureStorage();

Future<String?> _getBearerToken() async {
  try {
    // prefer secure storage
    log("Getting bearer token");
    final token = await _secureStorage.read(key: 'api_token');
    log("Bearer token: $token");
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString('api_key');
    if (legacy != null && legacy.isNotEmpty) return legacy;
    return null;
  } catch (e) {
    return null;
  }
}

/// Helper to POST JSON with optional bearer auth
Future<dynamic> postWithHeaders(String url, Map<String, dynamic> body, {bool requireAuth = true}) async {
  try {
    final token = await _getBearerToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else if (requireAuth) {
      throw Exception('Missing authentication token');
    }

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 418) {
      throw Exception('🔥 Boosters Désactivées.');
    } else if (response.statusCode == 429) {
      String text = jsonDecode(response.body)['detail'];
      return {"timeout": true, "message": text};
    } else if (response.statusCode == 499) {
      return { "timeout": true};
    } else if (response.statusCode == 500) {
      throw Exception('💣 Super erreur du serveur. Réessayez plus tard !');
    } else {
      final msg = response.body.isNotEmpty ? response.body : response.statusCode.toString();
      throw Exception('Request failed: $msg');
    }
  } catch (e) {
    print('Error in postWithHeaders: $e');
    final errorMessage = e.toString().replaceFirst('Exception: ', '');
    throw Exception(errorMessage);
  }
}

