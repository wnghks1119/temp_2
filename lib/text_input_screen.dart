import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db_helper.dart';


class TextInputScreen extends StatefulWidget {
  final DateTime selectedDate;

  const TextInputScreen({super.key, required this.selectedDate});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {

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


  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _filterMonthData(year, month) async {
    final monthData = await SQLHelper.getMonthData(year, month);
    setState(() {
      _monthData = monthData;
      _isLoading = false;
    });
    print("월 데이터");
    print(_monthData);
  }

  Future<void> _addData(year, month, day) async {
    await SQLHelper.createData(year, month, day, _descController.text);
    _refreshData();
    _filterMonthData(year, month);
  }

  Future<void> _updateData(year, month, day) async {
    await SQLHelper.updateData(year, month, day, _descController.text);
    _refreshData();
    _filterMonthData(year, month);
  }

  Future<void> _deleteData() async {
    await SQLHelper.deleteData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Data Deleted"),
    ));
    _refreshData();
  }

  final TextEditingController _descController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final selectedDate = widget.selectedDate;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "텍스트 입력 화면_first",
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
                    _addData(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
                    //_filterMonthData(widget.selectedDate.year, widget.selectedDate.month);
                    //_deleteData();

                    // Navigator.pop(context);


                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "저장",
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
