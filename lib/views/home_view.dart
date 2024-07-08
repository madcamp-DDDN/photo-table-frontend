import 'package:flutter/material.dart';
import 'package:photo_table/models/user_model.dart';
import 'package:photo_table/views/daily_photo_grid.dart';
import 'package:photo_table/views/weekly_photo_grid.dart';

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
    );
  }
}