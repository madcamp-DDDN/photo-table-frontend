import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class PhotoGrid extends StatefulWidget {
  final List<Photo?> photos;
  final int columnCount;
  final double fixedColumnWidth;
  final double photoWidth;
  final double photoHeight;
  final bool isWeekly;
  final User user;
  final DateTime selectedDate;
  final ScrollController? scrollController; // 추가: 스크롤 컨트롤러

  PhotoGrid({
    required this.photos,
    required this.columnCount,
    required this.fixedColumnWidth,
    required this.photoWidth,
    required this.photoHeight,
    required this.user,
    required this.selectedDate,
    this.isWeekly = false,
    this.scrollController, // 추가: 스크롤 컨트롤러
  });

  @override
  _PhotoGridState createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  late List<Photo?> photos;

  @override
  void initState() {
    super.initState();
    photos = widget.photos;
  }

  Future<void> _refreshPhoto(int photoIndex) async {
    final response = await ApiService.fetchPhotos(
      widget.user.id,
      widget.selectedDate.toIso8601String().substring(0, 10),
    );
    setState(() {
      photos[photoIndex] = response[photoIndex];
    });
  }

  void viewPhoto(BuildContext context, Photo? photo, int timeSlot, int photoIndex) async {
    if (photo == null || photo.id.isEmpty) {
      return; // 빈 사진이면 확대하지 않음
    }

    print('Attempting to view photo with id: ${photo.id}'); //사진 아이디 출력

    double screenWidth = MediaQuery.of(context).size.width;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: screenWidth,
                  height: (screenWidth / 3) * 4,
                  child: Image.network(photo.photoUrl, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      print('Attempting to delete photo with id: ${photo.id}'); //삭제하려는 사진 id
                      await ApiService.deletePhoto(photo.id);
                      Navigator.of(context).pop();
                      await _refreshPhoto(photoIndex);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo deleted successfully')),
                      );
                    } catch (error) {
                      print('Failed to delete photo: $error'); //삭제 실패 로그
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete photo')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    // Refresh the photo slot after viewing
    await _refreshPhoto(photoIndex);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    double totalHeight = widget.photoHeight * 12; // 총 높이 계산 (12개의 시간대)
    double currentTimePosition = ((now.hour * 60 + now.minute) / (24 * 60)) * totalHeight;

    return SingleChildScrollView(
      controller: widget.scrollController, // 수정: 스크롤 컨트롤러 사용
      scrollDirection: Axis.vertical,
      child: Stack(
        children: [
          LayoutGrid(
            columnSizes: [
              FixedTrackSize(widget.fixedColumnWidth),
              ...List.generate(widget.columnCount, (_) => FlexibleTrackSize(1)),
            ],
            rowSizes: List.generate(12, (index) => FixedTrackSize(widget.photoHeight)),
            rowGap: 0,
            columnGap: 0,
            children: [
              for (int i = 0; i < 12; i++) ...[
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(left: 0),
                  width: 60, // 추가: width를 40으로 설정
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF6c6c6c), // 추가: border 색상 설정
                      width: 0.5, // 추가: border 두께 설정
                    ),
                  ),
                  child: Text(
                    '${i * 2}',
                    style: TextStyle(color: Color(0xFF8c8c8c)), // 시간 텍스트 색상을 #8c8c8c로 설정
                  ),
                ).withGridPlacement(columnStart: 0, rowStart: i),
                for (int j = 0; j < widget.columnCount; j++) ...[
                  GestureDetector(
                    onTap: () {
                      int photoIndex = i * widget.columnCount + j;
                      if (photoIndex < photos.length && photos[photoIndex] != null && photos[photoIndex]!.id.isNotEmpty) {
                        viewPhoto(context, photos[photoIndex], i * 2, photoIndex);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF6c6c6c),
                          width: 0.5,
                        ), //
                        color: Color(0x80212024),
                      ),
                      width: widget.photoWidth,
                      height: widget.photoHeight,
                      child: (i * widget.columnCount + j) < photos.length && photos[i * widget.columnCount + j] != null && photos[i * widget.columnCount + j]!.id.isNotEmpty
                          ? Image.network(photos[i * widget.columnCount + j]!.photoUrl, fit: BoxFit.cover)
                          : Center(child: Text('')),
                    ),
                  ).withGridPlacement(columnStart: j + 1, rowStart: i),
                ],
              ],
            ],
          ),
          Positioned(
            top: currentTimePosition,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}