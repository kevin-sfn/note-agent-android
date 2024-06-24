import 'package:flutter/material.dart';

class NoteCalendar extends StatefulWidget {
  @override
  _NoteCalendarState createState() => _NoteCalendarState();
}

class _NoteCalendarState extends State<NoteCalendar> {
  final List<String> _daysOfWeek = [
    '수',
    '목',
    '금',
    '토',
    '일',
    '월',
    '화'
  ];
  final List<int> _daysInMonth = List.generate(31, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 열의 개수
            ),
            itemCount: 7, // 요일 헤더를 표시할 개수 (7일)
            itemBuilder: (BuildContext context, int index) {
              // 각 요일 헤더를 표시
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  border: Border.all(),
                ),
                child: Center(
                  child: Text(
                    _daysOfWeek[index], // 요일 표시
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 열의 개수
            ),
            itemCount: _daysInMonth.length, // 해당 월의 일 수에 맞춰 동적으로 설정
            itemBuilder: (BuildContext context, int index) {
              // index를 통해 각 날짜를 계산하여 표시
              return CalendarCell(date: _daysInMonth[index]);
            },
          ),
        ),
      ],
    );
  }
}

class CalendarCell extends StatelessWidget {
  final int date;

  const CalendarCell({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Text(
        '$date', // 날짜 표시
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NoteCalendar(),
  ));
}
