import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';


class TextInputLaterScreen extends StatefulWidget {
  final DateTime selectedDate;

  const TextInputLaterScreen({super.key, required this.selectedDate});

  @override
  State<TextInputLaterScreen> createState() => _TextInputLaterScreenState();
}

class _TextInputLaterScreenState extends State<TextInputLaterScreen> {

  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _monthData = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
    print("전체 데이터");
    print(_allData);
  }

  void _filterMonthData(year, month) async {
    final monthData = await SQLHelper.getMonthData(year, month);
    setState(() {
      _monthData = monthData;
      _isLoading = false;
    });
    print("월 데이터");
    print(_monthData);
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  /*
  Future<void> _addData(year, month, day, date) async {
    await SQLHelper.createData(year, month, day, _descController.text, date);
    _refreshData();
    _filterMonthData(year, month);
  }
   */

  Future<void> _updateDescData(year, month, day) async {
    await SQLHelper.updateDescData(year, month, day, _descController.text);
    _refreshData();
    _filterMonthData(year, month);
    print("데이터 업데이트");
  }

  final TextEditingController _descController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    print("텍스트 수정 화면으로 이동했습니다.");
    final selectedDate = widget.selectedDate;

    final index = _allData.firstWhere((element) => element['date'] == DateFormat('yyyy-MM-dd HH:mm').format(widget.selectedDate));
    // final dateString = DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);

    final existingData =
    _allData.firstWhere((element) => element['date'] == DateFormat('yyyy-MM-dd HH:mm').format(widget.selectedDate));
    _descController.text = existingData['Desc'];

    print("캘린더에서 선택한 날짜 데이터");
    print(existingData);


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "텍스트 입력 화면_later",
          ),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 "
                      "${DateFormat.EEEE('ko').format(selectedDate)}",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: _descController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    //filled: true,
                    //fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Colors.redAccent),
                    ),
                    border: OutlineInputBorder(),
                    labelText: "1. 감사한 일",
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  // 버튼 클릭 시 입력했던 데이터가 저장될 수 있도록 함수 추가 (createData -> _addData)
                  onPressed: () {
                    print("---------------수정 완료 버튼 클릭---------------");

                    _updateDescData(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
                    //_filterMonthData(widget.selectedDate.year, widget.selectedDate.month);

                    print("수정 후 전체 데이터");
                    print(_allData);

                    _descController.text = "";

                    Navigator.pop(context);


                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "수정 완료",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
