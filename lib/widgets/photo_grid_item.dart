import 'package:flutter/material.dart';

class PhotoGridItem extends StatelessWidget {
  final String photoUrl;

  PhotoGridItem({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: NetworkImage(photoUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}