import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;

typedef OnDaySelected = void Function(DateTime selectedDay, DateTime focusedDay);
typedef OnPageChanged = void Function(DateTime focusedDay);

class CalendarData {
  final String date;
  final double salesAmount;
  final double depositAmount;

  CalendarData(this.date, this.salesAmount, this.depositAmount);
}

class SfTableCalendar extends StatefulWidget {
  final List calendarDayList;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final OnDaySelected onDaySelected;
  final OnPageChanged? onPageChanged;
  final bool saleVisible;

  const SfTableCalendar({
    super.key,
    required this.calendarDayList,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
    required this.saleVisible,
  });

  @override
  State<SfTableCalendar> createState() => _SfTableCalendarState();
}

class _SfTableCalendarState extends State<SfTableCalendar> {
  Widget _buildCalendarDay({
    required String day,
    required Color backColor,
    required Color fontColor,
  }) {
    // calendarList에서 해당 날짜에 맞는 데이터를 찾습니다.
    var calendarData = widget.calendarDayList.firstWhere(
          (element) => element.date == day,
      orElse: () => null,
    );
    // 해당 날짜의 데이터가 없는 경우 기본 값을 사용합니다.
    String salesAmount = '';
    String depositAmount = '';
    if (calendarData != null) {
      salesAmount = (widget.saleVisible == true)
        ? intl.NumberFormat('#,###').format(calendarData.salesAmount)
        : '';
      depositAmount = intl.NumberFormat('#,###').format(calendarData.depositAmount);
    } else {
      salesAmount = (widget.saleVisible == true) ? '0' : '';
      depositAmount = '0';
    }

    String lastTwoChars = day.substring(day.length - 2);
    if (lastTwoChars.startsWith('0')) {
      lastTwoChars = lastTwoChars.substring(1);
    }
    return Container(
      // alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 1.0),
                  width: 24,
                  decoration: BoxDecoration(
                    color: backColor, // 배경색
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(lastTwoChars, style: TextStyle(fontSize: 12, color: fontColor ?? Colors.black)),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Row(children: [
            const Spacer(),
            Text(salesAmount,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color.fromRGBO(0x00, 0x00, 0xF1, 1.0),
              ),
            ),],),
          Row(children: [
            const Spacer(),
            Text(depositAmount,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 10, color: Color.fromRGBO(0x14, 0xB8, 0xA6, 1.0)),
            ),],),
        ],
      ),
    );
  }

  CalendarBuilders _calendarBuilder() {
    return CalendarBuilders(
      defaultBuilder: (context, date, _) {
        return _buildCalendarDay(
          day: intl.DateFormat('yyyyMMdd').format(date),
          backColor: Colors.white,
          fontColor: Colors.black,
        );
      },
      selectedBuilder: (context, date, _) {
        return _buildCalendarDay(
            day: intl.DateFormat('yyyyMMdd').format(date),
            backColor: Colors.blueAccent,
            fontColor: Colors.white);
      },
      todayBuilder: (context, date, _) {
        return _buildCalendarDay(
            day: intl.DateFormat('yyyyMMdd').format(date),
            backColor: Colors.white,
            fontColor: Colors.black);
      },
      holidayBuilder: (context, date, _) {
        return _buildCalendarDay(
            day: intl.DateFormat('yyyyMMdd').format(date),
            backColor: Colors.white,
            fontColor: Colors.red);
      },
      outsideBuilder: (context, date, _) {
        return _buildCalendarDay(
            day: intl.DateFormat('yyyyMMdd').format(date),
            backColor: Colors.white,
            fontColor: Colors.grey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: widget.focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(widget.selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDaySelected(selectedDay, focusedDay);
      },
      onPageChanged: (focusedDay) {
        if (kDebugMode) {
          print('${DateTime.now()}: SfTableCalendar.onPageChanged - focusedDay: $focusedDay');
        }
        if (widget.onPageChanged != null) {
          widget.onPageChanged!(focusedDay);
        }
      },
      calendarBuilders: _calendarBuilder(),
      rowHeight: 50,
      calendarStyle: const CalendarStyle(
        cellAlignment: Alignment.topLeft,
        defaultDecoration: BoxDecoration(color: Colors.white,),
        defaultTextStyle: TextStyle(fontSize: 12.0,),
        selectedTextStyle: TextStyle(fontSize: 12.0, color: Colors.green),
        selectedDecoration: BoxDecoration(color: Colors.white,),
        todayTextStyle: TextStyle(fontSize: 12.0, color: Colors.blue),
        todayDecoration: BoxDecoration(color: Colors.white,),
        outsideTextStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
        outsideDecoration: BoxDecoration(color: Colors.white,),
        holidayTextStyle: TextStyle(fontSize: 12.0, color: Colors.red),
        weekendTextStyle: TextStyle(fontSize: 12.0, color: Colors.red),
        weekendDecoration: BoxDecoration(color: Colors.white,),
      ),
      headerVisible: false,
    );
  }
}
