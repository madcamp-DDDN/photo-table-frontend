import 'package:flutter/material.dart';
import 'package:photo_table/models/user_model.dart';
import 'package:photo_table/views/daily_photo_grid.dart';
import 'package:photo_table/views/weekly_photo_grid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_table/services/api_service.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:http/http.dart' as http; // 수정: http 라이브러리 import 추가
import 'package:path_provider/path_provider.dart'; // 수정: path_provider import 추가
import '../dot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart'; // 추가: image_gallery_saver import

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

  // 사진을 merge 해서 export 하는 함수
  Future<void> _downloadMergedImage() async {
    // 스토리지 권한 요청
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 30) {
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission not granted')));
            return;
          }
        }
      } else {
        var manageStorageStatus = await Permission.manageExternalStorage.status;
        if (!manageStorageStatus.isGranted) {
          manageStorageStatus = await Permission.manageExternalStorage.request();
          if (!manageStorageStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Manage external storage permission not granted')));
            return;
          }
        }
      }
    } else {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission not granted')));
          return;
        }
      }
    }

    // 백엔드에서 합쳐진 이미지를 가져옴
    final response = await ApiService.fetchMergedPhotos(widget.user.id, selectedDate.toIso8601String().substring(0, 10)); // 수정: ApiService 사용

    if (response.statusCode == 200) {
      // 파일을 저장할 디렉토리를 가져옴
      final dir = await getApplicationDocumentsDirectory(); // 수정: getApplicationDocumentsDirectory 함수 사용
      final filePath = '${dir.path}/${widget.user.id}_${selectedDate.toIso8601String().substring(0, 10)}.jpg';
      final file = File(filePath);

      // 응답 본문을 파일로 작성
      await file.writeAsBytes(response.bodyBytes);

      // 파일을 갤러리에 저장
      final result = await ImageGallerySaver.saveFile(filePath); // 추가: 파일을 갤러리에 저장
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo saved to gallery: $filePath')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save photo to gallery')));
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo downloaded: $filePath')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download photo')));
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);

                if (image == null) return;

                // 권한 체크 및 요청 로직
                var status = await Permission.camera.status;
                if (!status.isGranted) {
                  status = await Permission.camera.request();
                  if (!status.isGranted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera permission not granted')));
                    return;
                  }
                }

                if (Platform.isAndroid) {
                  var androidInfo = await DeviceInfoPlugin().androidInfo;
                  if (androidInfo.version.sdkInt < 30) {
                    var storageStatus = await Permission.storage.status;
                    if (!storageStatus.isGranted) {
                      storageStatus = await Permission.storage.request();
                      if (!storageStatus.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission not granted')));
                        return;
                      }
                    }
                  } else {
                    var manageStorageStatus = await Permission.manageExternalStorage.status;
                    if (!manageStorageStatus.isGranted) {
                      manageStorageStatus = await Permission.manageExternalStorage.request();
                      if (!manageStorageStatus.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Manage external storage permission not granted')));
                        return;
                      }
                    }
                  }
                }

                final bool success = await ApiService.uploadPhoto(widget.user.id, selectedDate.toIso8601String().substring(0, 10), (selectedDate.hour ~/ 2) + 1, image.path);

                if (success) {
                  setState(() {
                    // Re-render the current grid to display the uploaded image
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload photo')));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

                if (image == null) return;

                // 권한 체크 및 요청 로직
                if (Platform.isAndroid) {
                  var androidInfo = await DeviceInfoPlugin().androidInfo;
                  if (androidInfo.version.sdkInt < 30) {
                    var storageStatus = await Permission.storage.status;
                    if (!storageStatus.isGranted) {
                      storageStatus = await Permission.storage.request();
                      if (!storageStatus.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Storage permission not granted')));
                        return;
                      }
                    }
                  } else {
                    var manageStorageStatus = await Permission.manageExternalStorage.status;
                    if (!manageStorageStatus.isGranted) {
                      manageStorageStatus = await Permission.manageExternalStorage.request();
                      if (!manageStorageStatus.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Manage external storage permission not granted')));
                        return;
                      }
                    }
                  }
                }

                final bool success = await ApiService.uploadPhoto(widget.user.id, selectedDate.toIso8601String().substring(0, 10), (selectedDate.hour ~/ 2) + 1, image.path);

                if (success) {
                  setState(() {
                    // Re-render the current grid to display the uploaded image
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload photo')));
                }
              },
            ),
          ],
        ),
      ),
    );
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
          IconButton(
            icon: Icon(Icons.download), // 다운로드 버튼
            onPressed: _downloadMergedImage, // 버튼을 누르면 _downloadMergedImage 함수 호출
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