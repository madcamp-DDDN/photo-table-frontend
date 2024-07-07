import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../widgets/photo_grid.dart';

class HomeView extends StatefulWidget {
  final User user;

  HomeView({required this.user});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Photo>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = _fetchPhotos();
  }

  Future<List<Photo>> _fetchPhotos() async {
    try {
      final date = DateTime.now().toIso8601String().split('T').first; // 현재 날짜를 사용합니다.
      final photos = await ApiService.fetchPhotos(widget.user.id, date);
      // 12개의 슬롯을 빈 이미지로 초기화
      List<Photo> slots = List.generate(12, (index) => Photo(id: '', uploadTimeSlot: index, photoUrl: ''));
      // 서버에서 가져온 이미지를 해당 슬롯에 추가
      for (var photo in photos) {
        slots[photo.uploadTimeSlot] = photo;
      }
      return slots;
    } catch (error) {
      print('Failed to fetch photos: $error');
      // 에러가 발생하면 12개의 빈 슬롯 반환
      return List.generate(12, (index) => Photo(id: '', uploadTimeSlot: index, photoUrl: ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Table'),
      ),
      body: FutureBuilder<List<Photo>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load photos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No photos available'));
          } else {
            return PhotoGrid(photos: snapshot.data!);
          }
        },
      ),
    );
  }
}