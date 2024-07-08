import 'package:flutter/material.dart';
import 'package:photo_table/services/api_service.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';

class DailyPhotoGrid extends StatelessWidget {
  final DateTime selectedDate;
  final User user;

  DailyPhotoGrid({required this.selectedDate, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Photo>>(
      future: ApiService.fetchPhotos(user.id, selectedDate.toIso8601String().substring(0, 10)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final photos = snapshot.data ?? [];
        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                minHeight: 50.0,
                maxHeight: 50.0,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Text(selectedDate.toIso8601String().substring(0, 10)),
                  ),
                ),
              ),
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final photo = photos.firstWhere(
                        (photo) => photo.uploadTimeSlot == index,
                    orElse: () => Photo(id: '', uploadTimeSlot: index, photoUrl: ''),
                  );

                  return Row(
                    children: [
                      Container(
                        width: 80,
                        height: 200,
                        alignment: Alignment.center,
                        child: Text('${index * 2}:00'),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (index == currentTimeSlot()) {
                              uploadPhotoDialog(context, selectedDate, index);
                            } else if (photo.id.isNotEmpty) {
                              viewPhoto(context, photo);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            color: Colors.grey[300],
                            height: 200,
                            child: photo.id.isNotEmpty
                                ? Image.network(photo.photoUrl, fit: BoxFit.cover)
                                : Center(child: Text('${index * 2}:00')),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  int currentTimeSlot() {
    final now = DateTime.now();
    if (now.day != selectedDate.day) return -1;
    return (now.hour ~/ 2) + 1;
  }

  void uploadPhotoDialog(BuildContext context, DateTime date, int timeSlot) {
    // 사진 업로드 다이얼로그를 구현합니다.
  }

  void viewPhoto(BuildContext context, Photo photo) {
    // 사진 확대 보기 기능을 구현합니다.
  }
}

class WeeklyPhotoGrid extends StatelessWidget {
  final DateTime selectedDate;
  final User user;

  WeeklyPhotoGrid({required this.selectedDate, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Photo>>(
      future: ApiService.fetchPhotos(user.id, selectedDate.toIso8601String().substring(0, 10)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final photos = snapshot.data ?? [];
        return Column(
          children: [
            Container(
              height: 50,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final date = selectedDate.add(Duration(days: index));
                  return Text('${date.month}-${date.day}');
                }),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: 84, // 7일 * 12개 슬롯
                itemBuilder: (context, index) {
                  final dayIndex = index % 7;
                  final timeSlot = index ~/ 7;
                  final date = selectedDate.add(Duration(days: dayIndex));
                  final photo = photos.firstWhere(
                        (photo) => photo.uploadTimeSlot == timeSlot,
                    orElse: () => Photo(id: '', uploadTimeSlot: timeSlot, photoUrl: ''),
                  );

                  return Column(
                    children: [
                      Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: Text('${timeSlot * 2}:00'),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (photo.id.isNotEmpty) {
                              viewPhoto(context, photo);
                            }
                          },
                          child: Container(
                            color: Colors.grey[300],
                            child: photo.id.isNotEmpty
                                ? Image.network(photo.photoUrl, fit: BoxFit.cover)
                                : Center(child: Text('${timeSlot * 2}:00')),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void viewPhoto(BuildContext context, Photo photo) {
    // 사진 확대 보기 기능을 구현합니다.
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent || minHeight != oldDelegate.minExtent || child != oldDelegate.child;
  }
}