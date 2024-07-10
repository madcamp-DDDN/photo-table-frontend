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
  final ScrollController? scrollController;

  PhotoGrid({
    required this.photos,
    required this.columnCount,
    required this.fixedColumnWidth,
    required this.photoWidth,
    required this.photoHeight,
    required this.user,
    required this.selectedDate,
    this.isWeekly = false,
    this.scrollController,
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
      return;
    }

    print('Attempting to view photo with id: ${photo.id}');

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
                      print('Attempting to delete photo with id: ${photo.id}');
                      await ApiService.deletePhoto(photo.id);
                      Navigator.of(context).pop();
                      await _refreshPhoto(photoIndex);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo deleted successfully')),
                      );
                    } catch (error) {
                      print('Failed to delete photo: $error');
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

    await _refreshPhoto(photoIndex);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    double totalHeight = widget.photoHeight * 12;
    double currentTimePosition = ((now.hour * 60 + now.minute) / (24 * 60)) * totalHeight;
    int currentHourSlot = now.hour ~/ 2;

    return SingleChildScrollView(
      controller: widget.scrollController,
      scrollDirection: Axis.vertical,
      child: LayoutGrid(
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
              width: 60,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: i == currentHourSlot ? Colors.white : Color(0xFF6c6c6c),
                    width: i == currentHourSlot ? 1.5 : 0.5,
                  ),
                  bottom: BorderSide(
                    color: i == currentHourSlot ? Colors.white : Color(0xFF6c6c6c),
                    width: i == currentHourSlot ? 1.5 : 0.5,
                  ),
                  left: BorderSide(
                    color: Color(0xFF6c6c6c),
                    width: 0.5,
                  ),
                  right: BorderSide(
                    color: Color(0xFF6c6c6c),
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                '${i * 2}',
                style: i == currentHourSlot ? TextStyle(color: Colors.white) : TextStyle(color: Color(0xFF8c8c8c)),
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
                    border: Border(
                      top: BorderSide(
                        color: i == currentHourSlot ? Colors.white : Color(0xFF6c6c6c),
                        width: i == currentHourSlot ? 1.5 : 0.5,
                      ),
                      bottom: BorderSide(
                        color: i == currentHourSlot ? Colors.white : Color(0xFF6c6c6c),
                        width: i == currentHourSlot ? 1.5 : 0.5,
                      ),
                      left: BorderSide(
                        color: Color(0xFF6c6c6c),
                        width: 0.5,
                      ),
                      right: BorderSide(
                        color: Color(0xFF6c6c6c),
                        width: 0.5,
                      ),
                    ),
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
    );
  }
}