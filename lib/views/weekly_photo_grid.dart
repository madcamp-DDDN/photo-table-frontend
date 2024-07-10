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
    double fixedColumnWidth = 20.0; // 눈금의 고정 너비
    double photoWidth = (screenWidth - fixedColumnWidth) / 7; // 각 사진의 너비 (7 열)
    // double photoHeight = (photoWidth / 3) * 4; // 가로 3: 세로 4 비율
    double photoHeight = photoWidth * 0.9;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'), // 배경 이미지 설정
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold( // Scaffold 추가
        backgroundColor: Colors.transparent, // Scaffold 배경색을 투명으로 설정
        body: FutureBuilder<List<Photo?>>(
          future: fetchWeeklyPhotos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final photos = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(27.0).copyWith(top: 100.0), // 패딩 추가, top 패딩을 100으로 설정
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
                children: [
                  Text(
                    '${selectedDate.month}/${selectedDate.day} ~ ${selectedDate.add(Duration(days: 6)).month}/${selectedDate.add(Duration(days: 6)).day}',
                    style: TextStyle(
                      fontSize: 18, // 폰트 크기 설정
                      fontWeight: FontWeight.w300, // 폰트 굵기 설정
                      color: Color(0xFF8c8c8c), // 텍스트 색상 설정
                    ),
                  ),
                  SizedBox(height: 5), // 텍스트와 그리드 사이에 간격 추가
                  Expanded(
                    child: PhotoGrid(
                      photos: photos,
                      columnCount: 7,
                      fixedColumnWidth: fixedColumnWidth,
                      photoWidth: photoWidth,
                      photoHeight: photoHeight,
                      user: user,
                      selectedDate: selectedDate,
                      isWeekly: true,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

  }
}