import 'package:flutter/material.dart';
import 'package:photo_table/services/api_service.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';
import '../widgets/photo_grid.dart';

class DailyPhotoGrid extends StatefulWidget {
  final DateTime selectedDate;
  final User user;

  DailyPhotoGrid({required this.selectedDate, required this.user});

  @override
  _DailyPhotoGridState createState() => _DailyPhotoGridState();
}

class _DailyPhotoGridState extends State<DailyPhotoGrid> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final int hour = now.hour;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double photoHeight = (MediaQuery.of(context).size.width - 60.0) / 3 * 4;
    final double position = hour * (photoHeight + 1); // +1 for possible row gap

    _scrollController.jumpTo(position - screenHeight / 2 + photoHeight / 2);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fixedColumnWidth = 30.0; // 눈금의 고정 너비
    double photoWidth = screenWidth - fixedColumnWidth; // 각 사진의 너비
    double photoHeight = (photoWidth / 3) * 4; // 가로 3: 세로 4 비율

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
          future: ApiService.fetchPhotos(widget.user.id, widget.selectedDate.toIso8601String().substring(0, 10)),
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
                    '${widget.selectedDate.toIso8601String().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 18, // 폰트 크기 설정
                      fontWeight: FontWeight.w200, // 폰트 굵기 설정
                      color: Color(0xFFa7a7a7),
                    ),
                  ),
                  SizedBox(height: 5), // 텍스트와 그리드 사이에 간격 추가
                  Expanded(
                    child: PhotoGrid(
                      scrollController: _scrollController, // 스크롤 컨트롤러 추가
                      photos: photos,
                      columnCount: 1,
                      fixedColumnWidth: fixedColumnWidth,
                      photoWidth: photoWidth,
                      photoHeight: photoHeight,
                      user: widget.user,
                      selectedDate: widget.selectedDate,
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