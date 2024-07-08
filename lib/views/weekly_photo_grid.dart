import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:photo_table/services/api_service.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';

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
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: LayoutGrid(
            columnSizes: [
              FixedTrackSize(fixedColumnWidth),
              ...List.generate(7, (_) => FlexibleTrackSize(1)),
            ],
            rowSizes: List.generate(12, (index) => FixedTrackSize(photoHeight)), // Padding 제거
            rowGap: 0, // Padding 제거
            columnGap: 0, // Padding 제거
            children: [
              for (int i = 0; i < 12; i++) ...[
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 8), // Padding 조정
                  child: Text('${i * 2}:00'),
                ).withGridPlacement(columnStart: 0, rowStart: i),
                for (int j = 0; j < 7; j++)
                  GestureDetector(
                    onTap: () {
                      final dayIndex = selectedDate.add(Duration(days: j));
                      if (photos.isNotEmpty && photos[i + j * 12].id.isNotEmpty) {
                        viewPhoto(context, photos[i + j * 12]);
                      }
                    },
                    child: Container(
                      color: Colors.grey[300],
                      width: photoWidth,
                      height: photoHeight,
                      child: photos.isNotEmpty && photos[i + j * 12].id.isNotEmpty
                          ? Image.network(photos[i + j * 12].photoUrl, fit: BoxFit.cover)
                          : Center(child: Text('${i * 2}:00')),
                    ),
                  ).withGridPlacement(columnStart: j + 1, rowStart: i),
              ],
            ],
          ),
        );
      },
    );
  }

  void viewPhoto(BuildContext context, Photo photo) {
    // 사진 확대 보기 기능을 구현합니다.
  }
}