import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';

class FriendListView extends StatefulWidget {
  final User user;

  FriendListView({required this.user});

  @override
  _FriendListViewState createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  late Future<List<Friend>> _friendsFuture;
  String? _friendToken;

  @override
  void initState() {
    super.initState();
    _friendsFuture = FriendService.fetchFriends(widget.user.id);
  }

  void _generateFriendLink() async {
    final token = await FriendService.generateFriendLink(widget.user.id);
    setState(() {
      _friendToken = token;
    });
    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend link generated and copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate friend link')),
      );
    }
  }

  void _acceptFriend(String token) async {
    final success = await FriendService.acceptFriend(token, widget.user.id);
    if (success) {
      setState(() {
        _friendsFuture = FriendService.fetchFriends(widget.user.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add friend')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.user.profileImageUrl),
            ),
            title: Text(widget.user.name),
          ),
          ElevatedButton(
            onPressed: _generateFriendLink,
            child: Text('Generate Friend Link'),
          ),
          if (_friendToken != null) ...[
            SelectableText(_friendToken!),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Enter friend token',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _acceptFriend,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Friend>>(
              future: _friendsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No friends found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final friend = snapshot.data![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend.profilePicUrl),
                      ),
                      title: Text(friend.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}