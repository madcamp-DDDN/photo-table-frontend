import 'package:flutter/material.dart';
import 'package:photo_table/services/api_service.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';
import '../widgets/photo_grid.dart';

class WeeklyPhotoGrid extends StatelessWidget {
  final DateTime selectedDate;
  final User user;

  WeeklyPhotoGrid({required this.selectedDate, required this.user});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fixedColumnWidth = 60.0; // 눈금의 고정 너비
    double photoWidth = (screenWidth - fixedColumnWidth) / 7; // 각 사진의 너비 (7 열)
    double photoHeight = (photoWidth / 3) * 4; // 가로 3: 세로 4 비율

    return FutureBuilder<List<Photo>>(
      future: ApiService.fetchPhotos(user.id, selectedDate.toIso8601String().substring(0, 10)),
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
          isWeekly: true,
        );
      },
    );
  }
}