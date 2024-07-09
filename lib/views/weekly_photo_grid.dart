import 'package:flutter/material.dart';
import 'package:photo_table/services/api_service.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';
import '../widgets/photo_grid.dart';

class WeeklyPhotoGrid extends StatelessWidget {
  final DateTime selectedDate;
  final User user;

  WeeklyPhotoGrid({required this.selectedDate, required this.user});

  Future<List<Photo?>> fetchWeeklyPhotos() async {
    List<Photo?> weeklyPhotos = List.generate(84, (index) => null); // 7일 * 12시간 = 84

    try {
      for (int i = 0; i < 7; i++) {
        DateTime date = selectedDate.add(Duration(days: i));
        List<Photo?> dailyPhotos = await ApiService.fetchPhotos(user.id, date.toIso8601String().substring(0, 10));
        for (int j = 0; j < 12; j++) {
          if (j < dailyPhotos.length) {
            weeklyPhotos[j * 7 + i] = dailyPhotos[j];
          }
        }
      }
    } catch (e) {
      print("Error fetching weekly photos: $e");
    }

    return weeklyPhotos;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fixedColumnWidth = 60.0; // 눈금의 고정 너비
    double photoWidth = (screenWidth - fixedColumnWidth) / 7; // 각 사진의 너비 (7 열)
    double photoHeight = (photoWidth / 3) * 4; // 가로 3: 세로 4 비율

    return FutureBuilder<List<Photo?>>(
      future: fetchWeeklyPhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final photos = snapshot.data ?? [];
        return PhotoGrid(
          photos: photos,
          columnCount: 7,
          fixedColumnWidth: fixedColumnWidth,
          photoWidth: photoWidth,
          photoHeight: photoHeight,
          user: user,
          selectedDate: selectedDate,
          isWeekly: true,
        );
      },
    );
  }
}