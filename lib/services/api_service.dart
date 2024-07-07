import 'package:http/http.dart' as http;
import 'dart:convert';
import '../dot.dart';
import '../models/photo_model.dart';

class ApiService {
  static Future<List<Photo>> fetchPhotos(String userId, String date) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/photos?user_id=$userId&date=$date');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> photosJson = jsonDecode(response.body)['photos'];
      return photosJson.map((json) => Photo(
          id: json['photo_data_id'],
          uploadTimeSlot: json['upload_time_slot'],
          photoUrl: json['photo_url']
      )).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  static Future<void> uploadPhoto(String userId, String date, int timeSlot, String filePath) async {
    final url = Uri.parse('${DotEnvConfig.apiBaseUrl}/api/upload');
    var request = http.MultipartRequest('POST', url)
      ..fields['user_id'] = userId
      ..fields['date'] = date
      ..fields['upload_time_slot'] = timeSlot.toString()
      ..files.add(await http.MultipartFile.fromPath('photo', filePath));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload photo');
    }
  }
}