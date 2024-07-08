import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:photo_table/services/api_service.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';

class DailyPhotoGrid extends StatelessWidget {
  final DateTime selectedDate;
  final User user;

  DailyPhotoGrid({required this.selectedDate, required this.user});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fixedColumnWidth = 60.0; // 눈금의 고정 너비
    double photoWidth = screenWidth - fixedColumnWidth; // 각 사진의 너비
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
              FlexibleTrackSize(1),
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
                GestureDetector(
                  onTap: () {
                    if (photos.isNotEmpty && photos[i].id.isNotEmpty) {
                      viewPhoto(context, photos[i]);
                    }
                  },
                  child: Container(
                    color: Colors.grey[300],
                    width: photoWidth,
                    height: photoHeight,
                    child: photos.isNotEmpty && photos[i].id.isNotEmpty
                        ? Image.network(photos[i].photoUrl, fit: BoxFit.cover)
                        : Center(child: Text('${i * 2}:00')),
                  ),
                ).withGridPlacement(columnStart: 1, rowStart: i),
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