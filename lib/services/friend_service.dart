import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dot.dart';
import '../models/friend_model.dart';

class FriendService {
  static Future<String?> generateFriendLink(String userId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/friends/generateFriendLink');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      return null;
    }
  }

  static Future<bool> acceptFriend(String token, String userId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/friends/acceptFriend');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'userId': userId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Friend>> fetchFriends(String userId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/user');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> friendsJson = jsonDecode(response.body)['friends'];
      return friendsJson.map((json) => Friend(id: json['id'], name: json['name'])).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }
}