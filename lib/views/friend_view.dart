import 'package:flutter/material.dart';
import 'package:photo_table/services/friend_service.dart';
import '../models/user_model.dart' as AppUser;
import '../models/friend_model.dart';
import 'package:flutter/services.dart';

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

          final userProfile = snapshot.data!;
          return Column(
            children: [
              ListTile(
                leading: userProfile.profileImageUrl.isNotEmpty
                    ? Image.network(userProfile.profileImageUrl)
                    : Icon(Icons.account_circle, size: 50),
                title: Text(userProfile.name.isNotEmpty ? userProfile.name : 'Unknown'),
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Enter friend link token'),
              ),
              ElevatedButton(
                onPressed: () => _acceptFriend(_controller.text),
                child: Text('Add Friend'),
              ),
              ElevatedButton(
                onPressed: _generateFriendLink,
                child: Text('Generate Friend Link'),
              ),
              Expanded(
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
                              ? Image.network(friend.profilePicUrl)
                              : Icon(Icons.account_circle, size: 50),
                          title: Text(friend.name.isNotEmpty ? friend.name : 'Unknown'),
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