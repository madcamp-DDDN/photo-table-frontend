import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../services/api_service.dart';
import '../models/user_model.dart' as AppUser;
import '../models/photo_model.dart';
import '../widgets/photo_grid.dart';

class FriendListView extends StatelessWidget {
  final Future<List<Friend>> friendsFuture;
  final Function(Friend) showFriendDailyPhotos;

  FriendListView({
    required this.friendsFuture,
    required this.showFriendDailyPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Friend>>(
      future: friendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No friends found', style: TextStyle(color: Colors.white)));
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            padding: EdgeInsets.zero, // ListView의 상부 패딩 제거
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final friend = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend.profilePicUrl),
                ),
                title: Text(friend.name, style: TextStyle(color: Colors.white)),
                onTap: () => showFriendDailyPhotos(friend),
              );
            },
          ),
        );
      },
    );
  }
}