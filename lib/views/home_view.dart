import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  // 이미지 픽커 추가
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';  // File 클래스 사용을 위해 추가
import 'package:photo_table/services/api_service.dart';  // ApiService 사용을 위해 추가
import '../models/user_model.dart';
import '../views/daily_photo_grid.dart';
import '../views/weekly_photo_grid.dart';

class HomeView extends StatefulWidget {
  final User user;

  HomeView({required this.user});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  DateTime selectedDate = DateTime.now();
  bool isWeeklyView = false;
  PageController _dailyPageController = PageController(initialPage: 5000);
  PageController _weeklyPageController = PageController(initialPage: 5000);

  final ImagePicker _picker = ImagePicker();

  void _onDailyPageChanged(int index) {
    setState(() {
      int offset = 5000 - index; // 초기 페이지에서의 오프셋 계산
      selectedDate = DateTime.now().subtract(Duration(days: offset));
    });
  }

  void _onWeeklyPageChanged(int index) {
    setState(() {
      int offset = 5000 - index; // 초기 페이지에서의 오프셋 계산
      selectedDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 + 7 * offset));
    });
  }

  void _toggleView() {
    setState(() {
      if (isWeeklyView) {
        int pageIndex = 5000 - DateTime.now().difference(selectedDate).inDays;
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _dailyPageController.jumpToPage(pageIndex);
        });
      } else {
        int pageIndex = 5000 - (DateTime.now().difference(selectedDate).inDays ~/ 7);
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _weeklyPageController.jumpToPage(pageIndex);
        });
      }
      isWeeklyView = !isWeeklyView;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Gallery'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _requestPermissions();
      final pickedFile = await _picker.pickImage(source: result);

      if (pickedFile != null) {
        await _uploadImage(File(pickedFile.path));
      }
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = int.parse(androidInfo.version.release);

      if (release < 11) {
        statuses = await [
          Permission.camera,
          Permission.storage,
        ].request();
      } else {
        statuses = await [
          Permission.camera,
          Permission.manageExternalStorage,
        ].request();
      }
    } else {
      statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();
    }

    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        throw Exception('Permission not granted: ${permission.toString()}');
      }
    });
  }

  Future<void> _uploadImage(File image) async {
    try {
      String userId = widget.user.id;
      String date = DateTime.now().toIso8601String().substring(0, 10);
      int timeSlot = (DateTime.now().hour / 2).floor();  // 2시간 간격으로 타임 슬롯 결정

      await ApiService.uploadPhoto(userId, date, timeSlot, image.path);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo uploaded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload photo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isWeeklyView
            ? '${selectedDate.month}-${selectedDate.day} ~ ${selectedDate.add(Duration(days: 6)).month}-${selectedDate.add(Duration(days: 6)).day}'
            : selectedDate.toIso8601String().substring(0, 10)),
        actions: [
          IconButton(
            icon: Icon(isWeeklyView ? Icons.view_day : Icons.view_week),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: isWeeklyView
          ? PageView.builder(
        controller: _weeklyPageController,
        onPageChanged: _onWeeklyPageChanged,
        reverse: false,
        itemBuilder: (context, index) {
          int offset = 5000 - index;
          DateTime startDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 + 7 * offset));
          return WeeklyPhotoGrid(selectedDate: startDate, user: widget.user);
        },
      )
          : PageView.builder(
        controller: _dailyPageController,
        onPageChanged: _onDailyPageChanged,
        reverse: false,
        itemBuilder: (context, index) {
          int offset = 5000 - index;
          DateTime currentDate = DateTime.now().subtract(Duration(days: offset));
          return DailyPhotoGrid(selectedDate: currentDate, user: widget.user);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        child: Icon(Icons.add),
      ),
    );
  }
}