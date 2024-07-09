import 'package:flutter/material.dart';
import 'package:photo_table/services/friend_service.dart';
import '../models/user_model.dart' as AppUser;
import '../models/friend_model.dart';
import 'package:flutter/services.dart';
import '../widgets/photo_grid.dart';
import '../models/photo_model.dart';
import '../services/api_service.dart';

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

  void _showFriendDailyPhotos(Friend friend) {//친구 시간표 불러오기
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Scaffold(
            appBar: AppBar(
              title: Text('${friend.name}\'s Photos'),
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
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
                  photos: photos,
                  columnCount: 1,
                  fixedColumnWidth: 60.0,
                  photoWidth: MediaQuery.of(context).size.width - 60.0,
                  photoHeight: (MediaQuery.of(context).size.width - 60.0) / 3 * 4,
                  user: AppUser.User(id: friend.id, name: friend.name, profileImageUrl: friend.profilePicUrl),
                  selectedDate: DateTime.now(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: FutureBuilder<AppUser.User>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching user profile: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found'));
          }

          final userProfile = snapshot.data!;//내 정보
          return Column(
            children: [
              ListTile(
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
                    : Icon(Icons.account_circle, size: 50),
                title: Text(userProfile.name.isNotEmpty ? userProfile.name : 'Unknown'),
              ),
              Padding(//friend link token
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter friend link token',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(// 버튼 두개
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _acceptFriend(_controller.text),
                            child: Text('Add Friend'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _generateFriendLink,
                            child: Text('Generate Friend Link'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(//friend list
                child: FutureBuilder<List<Friend>>(
                  future: _friends,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Error fetching friends: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text('No friends data found'));
                    }

                    final friends = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return ListTile(
                          leading: friend.profilePicUrl.isNotEmpty
                              ? Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(friend.profilePicUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              : Icon(Icons.account_circle, size: 50),
                          title: Text(friend.name.isNotEmpty ? friend.name : 'Unknown'),
                          onTap: () => _showFriendDailyPhotos(friend),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}