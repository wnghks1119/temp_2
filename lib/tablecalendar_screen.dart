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

  //int length = 0;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
    print("캘린더 화면 refreshData 함수 실행");
  }

  void _getMonthData(year, month) async {
    final monthData = await SQLHelper.getMonthData(year, month);
    setState(() {
      _monthData = monthData;
      _isLoading = false;
    });
    print("_getMonthData 함수 실행");
    print("조건으로 걸러낸 월 데이터");
    print(_monthData);
  }

  void _getDayData(date) async {
    final dayData = await SQLHelper.getDayData(date);
    setState(() {
      _dayData = dayData;
      _isLoading = false;
    });
    print("_getDayData 함수 실행");
    print("조건으로 걸러낸 일 데이터_함수");
    print(_dayData);
  }

  Future<int> _numDayData(date) async {
    //<List<Map<String, dynamic>>> _dayData = [];

    final _dayData = await SQLHelper.getDayData(date);
    final num = _dayData.length;

    return num;
    /*
    setState(() {
      _dayData = dayData;
      _isLoading = false;
    });

    print("_getDayData 함수 실행");
    print("조건으로 걸러낸 일 데이터_함수");
    print(_dayData);
     */
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDay = DateTime.now();
    _refreshData();
    print("-------------initState 완료----------------");
  }

  Future<void> _countDayData(year, month, day) async {
    final row =
        Sqflite.firstIntValue(await SQLHelper.countDayData(year, month, day));
    setState(() {
      count = row!;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2029, 12, 31),
              focusedDay: DateTime.now(),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                });

                print("-----------------선택한 날짜------------------");
                print(
                    '${selectedDay.year} / ${selectedDay.month} / ${selectedDay.day}');

                print("본문 _refresh 실행");
                _refreshData();

                print("본문 _getMonth 실행");
                _getMonthData(selectedDay.year, selectedDay.month);

                print("본문 _getDay 실행");
                _getDayData(DateFormat('yyyy-MM-dd HH:mm').format(selectedDay));

                /*
                _countDayData(
                    selectedDay.year, selectedDay.month, selectedDay.day);

                print('전체 데이터베이스 중 해당일자의 레코드 수 : $count');
                 */

                print("*****전체 데이터*****");
                print(_allData);

                print("*****조건으로 걸러낸 월 데이터_본문*****");
                print(_monthData);

                print("*****조건으로 걸러낸 일 데이터_본문*****");
                print(_dayData);
                print(_dayData?.length);


                if (_dayData?.length == 0) {
                  print("기존 일 데이터 없음");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TextInputScreen(
                              selectedDate: selectedDay,
                            )),
                  );
                } else {
                  print("기존 일 데이터 존재!!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TextInputLaterScreen(
                              selectedDate: selectedDay,
                            )),
                  );
                }

                /*
                final index = _allData.firstWhere((element) =>
                element['date'] ==
                    DateFormat('yyyy-MM-dd HH:mm').format(selectedDay));
                final dateString = DateFormat('yyyy-MM-dd HH:mm').format(
                    selectedDay);

                print(index);
                if (index == null) {
                  print("첫 실행 시 나오는 화면으로 이동");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TextInputScreen(
                              selectedDate: selectedDay,
                            )),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TextInputLaterScreen(
                              selectedDate: selectedDay,
                            )),
                  );
                }

                 */

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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.large(
                  onPressed: () {
                    print("플로팅버튼 클릭");
                    print("<<<<<<<<<<전체 데이터>>>>>>>>>>");
                    print(_allData);
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
