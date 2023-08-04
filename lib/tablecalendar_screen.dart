import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:temp/text_input_late_screen.dart';
import 'package:temp/text_input_screen.dart';

import 'db_helper.dart';


class TableCalendarScreen extends StatefulWidget {
  const TableCalendarScreen({super.key});

  @override
  State<TableCalendarScreen> createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<TableCalendarScreen> {
  DateTime? selectedDay;

  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _monthData = [];
  List<Map<String, dynamic>> _dayData = []; // 화면 전환 시, 조건 분류용

  bool _isLoading = true;
  int count = 0;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDay = DateTime.now();
    _refreshData();
  }

  Future<void> _countDayData(year, month, day) async {
    final row = Sqflite.firstIntValue(await SQLHelper.countDayData(year, month, day));
    setState(() {
      count = row!;
      _isLoading = false;
    });
  }

  Future<void> _getMonthDate(year, month) async {
    final monthData = await SQLHelper.getMonthData(year, month);
    setState(() {
      _monthData = monthData;
      _isLoading = false;
    });
  }

  Future<void> _getDayDate(date) async {
    final day = await SQLHelper.getDayData(date);
    setState(() {
      _dayData = day;
      _isLoading = false;
    });
  }

  /*
  Future<void> _selectDayData(year, month, day) async {
    final data = await SQLHelper.getDayData(year, month, day);
    setState(() {
      _tempData = data;
      _isLoading = false;
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2029, 12, 31),
          focusedDay: DateTime.now(),
          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
            setState(() {
              this.selectedDay = selectedDay;
            });

            /*
            _countDayData(
                selectedDay.year, selectedDay.month, selectedDay.day);

            print('전체 데이터베이스 중 해당일자의 레코드 수 : $count');
             */

            _refreshData();
            print(_allData);

            print("선택한 날짜");
            print('${selectedDay.year} / ${selectedDay.month} / ${selectedDay.day}');
            print(selectedDay.year.runtimeType);


            _getMonthDate(selectedDay.year, selectedDay.month);
            print("조건으로 걸러낸 월 데이터");
            print(_monthData);
            /*
            _getDayDate(DateFormat('yyyy-MM-dd HH:mm').format(selectedDay));
            print("조건으로 걸러낸 일 데이터");
            print(_dayData);
            */


            if (count == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TextInputScreen(
                      selectedDate: selectedDay,
                    )),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TextInputLaterScreen(
                      selectedDate: selectedDay,
                    )),
              );
            }
          },
          selectedDayPredicate: (DateTime date) {
            if (selectedDay == null) {
              return false;
            }

            return date.year == selectedDay!.year &&
                date.month == selectedDay!.month &&
                date.day == selectedDay!.day;
          },
          headerStyle: HeaderStyle(
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            formatButtonVisible: false,
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(
              color: Colors.black,
            ),
            weekendTextStyle: TextStyle(
              color: Colors.grey,
            ),
            outsideDaysVisible: false,
            isTodayHighlighted: false,
            todayDecoration: BoxDecoration(
              color: Color(0xFF9FA8DA),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
