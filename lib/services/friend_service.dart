import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dot.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart' as AppUser;

class FriendService {
  static Future<String?> generateFriendLink(String userId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/friends/generateFriendLink');
    final response = await http.post(url, body: {'userId': userId});

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
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'token': token, 'userId': userId},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Friend>> fetchFriends(String userId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/friends/list?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> friendsJson = jsonDecode(response.body)['friends'];
      return friendsJson.map((json) => Friend(id: json['friend_id'], name: json['name'], profilePicUrl: json['profile_pic_url'])).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  static Future<AppUser.User> fetchUserProfile(String userId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/user?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return AppUser.User(
        id: userId,
        name: json['name'] ?? 'Unknown',
        profileImageUrl: json['profile_image_url'] ?? '',
      );
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}