import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';
import '../widgets/friend_list.dart';

class FriendView extends StatefulWidget {
  final User user;

  FriendView({required this.user});

  @override
  _FriendViewState createState() => _FriendViewState();
}

class _FriendViewState extends State<FriendView> {
  List<Friend> friends = [];
  String? token;
  TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      List<Friend> loadedFriends = await FriendService.fetchFriends(widget.user.id);
      setState(() {
        friends = loadedFriends;
      });
    } catch (e) {
      print('Failed to load friends: $e');
    }
  }

  Future<void> _generateFriendLink() async {
    String? newToken = await FriendService.generateFriendLink(widget.user.id);
    if (newToken != null) {
      setState(() {
        token = newToken;
      });
      Clipboard.setData(ClipboardData(text: newToken));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link copied to clipboard')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate link')));
    }
  }

  Future<void> _acceptFriend() async {
    String inputToken = _tokenController.text;
    print("accept");
    print(inputToken);
    print(widget.user.id);
    bool success = await FriendService.acceptFriend(inputToken, widget.user.id);
    if (success) {
      _tokenController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend added successfully')));
      _loadFriends();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add friend')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: Column(
        children: [
          FriendList(friends: friends),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateFriendLink,
            child: Text('Generate Friend Link'),
          ),
          if (token != null) Text('Token: $token'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _tokenController,
              decoration: InputDecoration(labelText: 'Enter Token'),
            ),
          ),
          ElevatedButton(
            onPressed: _acceptFriend,
            child: Text('Add Friend'),
          ),
        ],
      ),
    );
  }
}