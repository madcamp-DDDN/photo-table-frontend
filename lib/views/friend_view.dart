import 'package:flutter/material.dart';
import 'package:photo_table/services/friend_service.dart';
import '../models/user_model.dart' as AppUser;
import '../models/friend_model.dart';
import 'package:flutter/services.dart';
import 'friend_list_view.dart';
import '../models/photo_model.dart';
import '../services/api_service.dart';
import '../widgets/photo_grid.dart';

class FriendView extends StatefulWidget {
  final AppUser.User user;

  FriendView({required this.user});

  @override
  _FriendViewState createState() => _FriendViewState();
}

class _FriendViewState extends State<FriendView> {
  late Future<List<Friend>> _friends;
  late Future<AppUser.User> _userProfile;

  @override
  void initState() {
    super.initState();
    _friends = FriendService.fetchFriends(widget.user.id);
    _userProfile = FriendService.fetchUserProfile(widget.user.id);
  }

  void _generateFriendLink() async {
    final token = await FriendService.generateFriendLink(widget.user.id);
    if (token != null) {
      Clipboard.setData(ClipboardData(text: token));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend link copied to clipboard')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate friend link')));
    }
  }

  void _acceptFriend(String token) async {
    final success = await FriendService.acceptFriend(token, widget.user.id);
    if (success) {
      setState(() {
        _friends = FriendService.fetchFriends(widget.user.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend added successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add friend')));
    }
  }

  void _showFriendDailyPhotos(Friend friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.black,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: FutureBuilder<List<Photo?>>(
                future: ApiService.fetchPhotos(friend.id, DateTime.now().toIso8601String().substring(0, 10)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final photos = snapshot.data ?? [];
                  return PhotoGrid(
                    scrollController: ScrollController(),
                    photos: photos,
                    columnCount: 1,
                    fixedColumnWidth: 30.0,
                    photoWidth: MediaQuery.of(context).size.width - 30.0,
                    photoHeight: (MediaQuery.of(context).size.width - 30.0) * 0.9,
                    user: AppUser.User(id: friend.id, name: friend.name, profileImageUrl: friend.profilePicUrl),
                    selectedDate: DateTime.now(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddFriendDialog() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Add Friend',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter friend link token',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _acceptFriend(_controller.text);
                        Navigator.of(context).pop();
                      },
                      child: Text('Add Friend'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _generateFriendLink();
                        Navigator.of(context).pop();
                      },
                      child: Text('Generate Friend Link'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'), // 배경 이미지 설정
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Padding(
            padding: const EdgeInsets.only(left: 10.0), // AppBar의 title에 좌우 패딩 추가
            child: Image.asset(
              'assets/logo1.png', // 로고 이미지 경로 설정
              height: 40, // 로고 이미지 높이 설정
            ),
          ),
          actions: [
            IconButton(
              padding: const EdgeInsets.only(right: 10.0),
              icon: Icon(Icons.person_add, color: Colors.white),
              onPressed: _showAddFriendDialog,
            ),
          ],
        ),
        body: FutureBuilder<AppUser.User>(
          future: _userProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error fetching user profile: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No user data found', style: TextStyle(color: Colors.white)));
            }

            final userProfile = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0),
                  child: ListTile(
                    leading: userProfile.profileImageUrl.isNotEmpty
                        ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(userProfile.profileImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : Icon(Icons.account_circle, size: 50, color: Colors.white),
                    title: Text(
                      userProfile.name.isNotEmpty ? userProfile.name : 'Unknown',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: Colors.grey),
                ),
                Expanded(
                  child: FriendListView(
                    friendsFuture: _friends,
                    showFriendDailyPhotos: _showFriendDailyPhotos,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}