import 'package:flutter/material.dart';
import '../models/photo_model.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;

  PhotoGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 그리드의 열 수
        crossAxisSpacing: 4.0, // 열 간의 간격
        mainAxisSpacing: 4.0, // 행 간의 간격
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GridTile(
          child: photo.photoUrl.isNotEmpty
              ? Image.network(photo.photoUrl, fit: BoxFit.cover)
              : Container(
            color: Colors.grey[200],
            child: Icon(Icons.photo, size: 50, color: Colors.grey),
          ),
        );
      },
    );
  }
}