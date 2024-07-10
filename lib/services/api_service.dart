import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dot.dart';
import '../models/photo_model.dart';

class ApiService {
  static final BaseCacheManager _cacheManager = DefaultCacheManager();

  static Future<List<Photo?>> fetchPhotos(String userId, String date) async {
    final url = '${DotEnvConfig.apiBaseUrl}/api/photos?user_id=$userId&date=$date';
    final file = await _cacheManager.getSingleFile(url);

    if (file != null) {
      final response = await file.readAsString();
      if (response.isNotEmpty) {
        List<dynamic> photosJson = jsonDecode(response)['photos'];
        return photosJson.map((json) {
          if (json == null) {
            return null;
          } else {
            return Photo(
              id: json['photo_data_id'],
              uploadTimeSlot: json['upload_time_slot'],
              photoUrl: json['photo_url'],
            );
          }
        }).toList();
      }
    }
    throw Exception('Failed to load photos');
  }

  static Future<bool> uploadPhoto(String userId, String date, int timeSlot, String filePath) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/upload');
    var request = http.MultipartRequest('POST', url)
      ..fields['user_id'] = userId
      ..fields['date'] = date
      ..fields['upload_time_slot'] = timeSlot.toString()
      ..files.add(await http.MultipartFile.fromPath('photo', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<http.Response> fetchPhoto(String photoId) async {
    final url = '${DotEnvConfig.apiBaseUrl}/api/photos/$photoId';
    final file = await _cacheManager.getSingleFile(url);

    if (file != null) {
      final response = await file.readAsString();
      if (response.isNotEmpty) {
        return http.Response(response, 200);
      }
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await _cacheManager.putFile(url, response.bodyBytes);
      return response;
    } else {
      throw Exception('Failed to fetch photo');
    }
  }

  static Future<http.Response> fetchMergedPhotos(String userId, String date) async {
    final url = '${DotEnvConfig.apiBaseUrl}/api/merge-photos?user_id=$userId&date=$date';
    final response = await http.get(Uri.parse(url));
    return response;
  }

  static Future<void> deletePhoto(String photoId) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/photos/$photoId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to delete photo: ${responseBody['error']}');
    }
  }
}