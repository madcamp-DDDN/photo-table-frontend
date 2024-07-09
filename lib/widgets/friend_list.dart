import 'package:flutter/material.dart';
import '../models/friend_model.dart';

class FriendList extends StatelessWidget {
  final List<Friend> friends;

  FriendList({required this.friends});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(friends[index].name),
          );
        },
      ),
    );
  }
}