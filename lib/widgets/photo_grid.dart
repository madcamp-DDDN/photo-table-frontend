import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo_model.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final int columnCount;
  final double fixedColumnWidth;
  final double photoWidth;
  final double photoHeight;
  final bool isWeekly;

  PhotoGrid({
    required this.photos,
    required this.columnCount,
    required this.fixedColumnWidth,
    required this.photoWidth,
    required this.photoHeight,
    this.isWeekly = false,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    double totalHeight = photoHeight * 12; // 총 높이 계산 (12개의 시간대)
    double currentTimePosition = ((now.hour * 60 + now.minute) / (24 * 60)) * totalHeight;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        children: [
          LayoutGrid(
            columnSizes: [
              FixedTrackSize(fixedColumnWidth),
              ...List.generate(columnCount, (_) => FlexibleTrackSize(1)),
            ],
            rowSizes: List.generate(12, (index) => FixedTrackSize(photoHeight)),
            rowGap: 0,
            columnGap: 0,
            children: [
              for (int i = 0; i < 12; i++) ...[
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 8),
                  child: Text('${i * 2}:00'),
                ).withGridPlacement(columnStart: 0, rowStart: i),
                for (int j = 0; j < columnCount; j++)
                  GestureDetector(
                    onTap: () {
                      if (photos.isNotEmpty && photos[i + j * 12].id.isNotEmpty) {
                        viewPhoto(context, photos[i + j * 12], i * 2);
                      }
                    },
                    child: Container(
                      color: Colors.grey[300],
                      width: photoWidth,
                      height: photoHeight,
                      child: photos.isNotEmpty && photos[i + j * 12].id.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: photos[i + j * 12].photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                      )
                          : Center(child: Text('${i * 2}:00')),
                    ),
                  ).withGridPlacement(columnStart: j + 1, rowStart: i),
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

  void viewPhoto(BuildContext context, Photo? photo, int timeSlot) {
    if (photo == null || photo.id.isEmpty) {
      return; // 빈 사진이면 확대하지 않음
    }

    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: screenWidth,
              height: (screenWidth / 3) * 4,
              child: CachedNetworkImage(
                imageUrl: photo.photoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
              ),
            ),
          ),
        );
      },
    );
  }
}