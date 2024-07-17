import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:flutter/painting.dart';
import 'package:intl/intl.dart' as intl;
import 'package:note_agent_flutter/data/do_dashboard_sales_payment.dart';
import '/component/sf_table_calendar.dart';
import '/common/api_service.dart';
import '/common/app_util.dart';

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  late DoDashboardSalesPayment dashboardSalesPayment;
  late Map<String, dynamic> salePaymentData;
  bool _isLoading = true; // 로딩 상태를 나타내는 변수
  final List _chartList = List.empty(growable: true);
  final List _calendarDayList = List.empty(growable: true);

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime _focusedDay = DateTime.now();
  DateTime _lastScrappingTime = DateTime.now();

  double _totalSalesAmount = 0.0;
  double _totalDepositAmount = 0.0;
  int _totalCount = 0;

  void calculateTotalAmount() {
    _totalSalesAmount = 0.0;
    _totalDepositAmount = 0.0;
    _totalCount = 0;

    // focusedDay를 yyyyMM 형식의 문자열로 변환
    String focusedMonth = intl.DateFormat('yyyyMM').format(_focusedDay);

    for (var item in _calendarDayList) {
      // item의 날짜를 yyyyMM 형식의 문자열로 변환
      String itemMonth = item.date.substring(0, 6);

      if (itemMonth == focusedMonth) {
        // if (kDebugMode) {
        //   print('calculateTotalAmount - item.date: ${item.date} (this month)');
        // }

        _totalSalesAmount += item.salesAmount;
        _totalDepositAmount += item.depositAmount;
        _totalCount++;
      } else {
        // if (kDebugMode) {
        //   print('calculateTotalAmount - item.date: ${item.date} (NOT this month)');
        // }
      }
    }

    if (kDebugMode) {
      print('Total Sales Amount: $_totalSalesAmount');
      print('Total Deposit Amount: $_totalDepositAmount');
      print('Total Count: $_totalCount');
    }

    setState(() {
      _totalSalesAmount = _totalSalesAmount;
      _totalCount = _totalCount;
    });
  }

  double calculateSalesAmount(
      DateTime startDate, DateTime endDate, List? calendarDayList) {
    // Null check for calendarDayList
    if (calendarDayList == null) {
      return 0;
    }

    double totalSalesAmount = 0;

    for (var item in calendarDayList) {
      DateTime itemDate = DateTime.parse(item.date);
      if (itemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          itemDate.isBefore(endDate)) {
        // if (kDebugMode) {
        //   print('calculateSalesAmount - itemDate: $itemDate, salesAmount: ${item.salesAmount}');
        // }

        totalSalesAmount += item.salesAmount;
      }
    }

    return totalSalesAmount;
  }

  void _refresh(BuildContext context) async {
    // String salesDate = '20240415';
    String salesDate =
        DateTime.now().toString().substring(0, 10).replaceAll('-', '');

    // 시작일 계산: 이번 달의 시작일부터 2주 전
    DateTime now = DateTime.now();
    DateTime startDate =
        DateTime(now.year, now.month, 1).subtract(const Duration(days: 14));

    // 종료일 계산: 이번 달의 마지막 날부터 1주 후
    DateTime endDate = ((now.month < 12)
            ? DateTime(now.year, now.month + 1, 1)
            : DateTime(now.year + 1, 1, 1))
        .add(const Duration(days: 7));

    // _chartList.clear();
    // calculateTotalAmount();

    try {
      TApiResponse response = await ApiService.getSalesPayment(salesDate);
      // 조회 성공 시 처리
      if (response.code == 200) {
        salePaymentData = response.data['data'];
        if (kDebugMode) {
          print('getSalesPayment - data: $salePaymentData');
        }
        dashboardSalesPayment =
            DoDashboardSalesPayment.fromJson(salePaymentData);
      }

      response = await ApiService.getSalesDeposit(
        startDate.toString().substring(0, 10).replaceAll('-', ''),
        endDate.toString().substring(0, 10).replaceAll('-', ''),
      );
      // 조회 성공 시 처리
      if (response.code == 200) {
        _calendarDayList.clear();

        var data = response.data['data'];
        if (data is List) {
          for (var item in data) {
            // if (kDebugMode) {
            //   print('getSalesDeposit - data: $item');
            // }
            String date = item['date'].toString();
            double salesAmount = item['salesAmount'].toDouble();
            double depositAmount = item['depositAmount'].toDouble();
            _calendarDayList
                .add(CalendarData(date, salesAmount, depositAmount));
          }

          calculateTotalAmount();
          initChartList(DateTime.now());
        } else {
          // if (kDebugMode) {
          //   print('getSalesDeposit - data: $data');
          // }
        }
      }
      response = await ApiService.getPosScrapingTime('AGENT-1');
      // 조회 성공 시 처리
      if (response.code == 200) {
        var data = response.data['data'];
        if (kDebugMode) {
          print('getPosScrapingTime - data: $data');
        }
        // data가 문자열로 제공되는 경우, DateTime으로 변환합니다.
        if (data is String) {
          setState(() {
            _lastScrappingTime = DateTime.parse(data);
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // 조회 실패 시 처리
      if (kDebugMode) {
        print('조회 실패: $e');
      }
      // TODO: 조회 실패 시 오류 메시지를 사용자에게 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('조회 실패'),
            content: Text('오류 메시지: $e'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  void initChartList(DateTime date) {
    _chartList.clear();
    for (int i = 6; i >= 0; i--) {
      DateTime targetDate = date.subtract(Duration(days: i));
      String formattedDate = intl.DateFormat('yyyyMMdd').format(targetDate);
      var calendarData = _calendarDayList.firstWhere(
        (element) => element.date == formattedDate,
        orElse: () => CalendarData(formattedDate, 0, 0),
      );
      if (calendarData != null) {
        _chartList.add(CalendarData(
          intl.DateFormat('M/d(E)', 'ko_KR').format(targetDate),
          // M/D(요일) 형식으로 변환
          calendarData.salesAmount,
          calendarData.depositAmount, // 판매액
        ));
      }
    }
  }

  void onCalendarDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // 선택된 날짜의 상태를 갱신합니다.
    initChartList(focusedDay);
    setState(() {
      this.selectedDay = selectedDay;
      this._focusedDay = focusedDay;
    });
  }

  void onCalendarPageChanged(DateTime focusedDay) {
    if (kDebugMode) {
      print(
          '${DateTime.now()}: _DashboardAppState.onCalendarPageChanged - focusedDay: $focusedDay');
    }
    setState(() {
      _focusedDay = focusedDay;
      _refresh(context);
    });
  }

  @override
  void initState() {
    super.initState();

    _refresh(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
// 현재 시간 구하기
    DateTime now = DateTime.now();
// 시간 차이 계산
    Duration difference = now.difference(_lastScrappingTime);
// 차이를 일, 시간, 분 단위로 계산
    int daysDifference = difference.inDays;
    int hoursDifference = difference.inHours % 24;
    int minutesDifference = difference.inMinutes % 60;

    String updateMessage = '';

// D일 H시간 m분 전 형식으로 메시지 생성
    if (daysDifference > 0) {
      updateMessage =
          '$daysDifference일 $hoursDifference시간 $minutesDifference분 전';
    } else if (hoursDifference > 0) {
      updateMessage = '$hoursDifference시간 $minutesDifference분 전';
    } else {
      updateMessage = '$minutesDifference분 전';
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 238, 252, 1.0),
      body: _isLoading // 로딩 상태에 따라 다른 위젯을 표시
          ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(4.0),
                  child: Row(
                      // 주 축을 양 끝으로 정렬
                      children: [
                        Text(
                          '마지막 업데이트: $updateMessage',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 160,
                          height: 40,
                          margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white),
                            color: Colors.white,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.circle,
                                color: Color.fromRGBO(0x00, 0x00, 0xF1, 1.0),
                                size: 24,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text('매출'),
                              Spacer(),
                              Icon(
                                Icons.circle,
                                color: Color.fromRGBO(0x14, 0xB8, 0xA6, 1.0),
                                size: 24,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text('입금'),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 400,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ),
                                padding: const EdgeInsets.all(16),
                                // 마진 설정
                                decoration: BoxDecoration(
                                  color: Colors.white, // 배경색
                                  borderRadius:
                                      BorderRadius.circular(16.0), // 모서리 라운드 처리
                                ),
                                // height: 420.0,
                                child: _buildDashboardSalesPayment(
                                    dashboardSalesPayment:
                                        dashboardSalesPayment),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white, // 배경색
                                  borderRadius:
                                      BorderRadius.circular(16.0), // 모서리 라운드 처리
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      // 모든 방향에 동일한 여백 설정
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '오늘 입금 예정',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${dashboardSalesPayment.depositCount}건',
                                            style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      AppUtil.formatPrice(
                                          dashboardSalesPayment.depositAmount),
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 30,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ),
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 16, right: 16, bottom: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white, // 배경색
                                  borderRadius:
                                      BorderRadius.circular(16.0), // 모서리 라운드 처리
                                ),
                                // height: 230.0,
                                child: Center(
                                  child: _buildDashboardSalesBarChart(
                                    data: [],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 60,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            // 이전 이동 버튼
                                            icon:
                                                const Icon(Icons.chevron_left),
                                            onPressed: () {
                                              // 이전 이동 버튼이 눌렸을 때 수행할 동작
                                              setState(() {
                                                _focusedDay = DateTime(
                                                    _focusedDay.year,
                                                    _focusedDay.month - 1,
                                                    1);
                                              });
                                              _refresh(context);
                                            },
                                          ),
                                          // const SizedBox(width: 8.0),
                                          Text(
                                            intl.DateFormat('yyyy년 M월')
                                                .format(_focusedDay),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // const SizedBox(width: 8.0),
                                          IconButton(
                                            // 다음 이동 버튼
                                            icon:
                                                const Icon(Icons.chevron_right),
                                            onPressed: () {
                                              // 다음 이동 버튼이 눌렸을 때 수행할 동작
                                              setState(() {
                                                _focusedDay = DateTime(
                                                    _focusedDay.year,
                                                    _focusedDay.month + 1,
                                                    1);
                                              });
                                              _refresh(context);
                                            },
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${_focusedDay.month}월 평균 매출',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            AppUtil.formatPrice(_totalCount > 0
                                                ? (_totalSalesAmount ~/
                                                        _totalCount)
                                                    .toInt()
                                                : 0),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: SfTableCalendar(
                                          calendarDayList: _calendarDayList,
                                          selectedDay: selectedDay,
                                          focusedDay: _focusedDay,
                                          onDaySelected: onCalendarDaySelected,
                                          onPageChanged: onCalendarPageChanged,
                                          saleVisible: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDashboardSalesPayment(
      {required DoDashboardSalesPayment dashboardSalesPayment}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '어제 전체 매출',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('${dashboardSalesPayment.totalCount}건'),
            // Text('0건'),
          ],
        ),
        Text(
          AppUtil.formatPrice(dashboardSalesPayment.totalAmount),
          style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        _buildDashboardSalesPaymentDetail(
          imagePath: 'assets/images/dashboard_card.png', // 이미지 파일 경로
          name: '카드매출',
          quantity: dashboardSalesPayment.creditCardCount,
          amount: dashboardSalesPayment.creditCardAmount,
        ),
        _buildDashboardSalesPaymentDetail(
          imagePath: 'assets/images/dashboard_cash.png', // 이미지 파일 경로
          name: '현금매출',
          quantity: dashboardSalesPayment.cashCount,
          amount: dashboardSalesPayment.cashAmount,
        ),
        _buildDashboardSalesPaymentDetail(
          imagePath: 'assets/images/dashboard_delivery.png', // 이미지 파일 경로
          name: '배달매출',
          quantity: dashboardSalesPayment.deliveryCount,
          amount: dashboardSalesPayment.deliveryAmount,
        ),
        _buildDashboardSalesPaymentDetail(
          imagePath: 'assets/images/dashboard_others.png', // 이미지 파일 경로
          name: '기타매출',
          quantity: dashboardSalesPayment.othersCount,
          amount: dashboardSalesPayment.othersAmount,
        ),
      ],
    );
  }

  Widget _buildDashboardSalesPaymentDetail({
    required String imagePath,
    required String name,
    required int quantity,
    required int amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0), // 모든 방향에 동일한 여백 설정
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            imagePath,
          ),
          const SizedBox(width: 16.0), // 이미지와 텍스트 사이 간격 조절
          // 왼쪽에 텍스트
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                '$quantity건',
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(), // 텍스트를 우측 끝으로 밀어냄
          Text(
            AppUtil.formatPrice(amount),
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSalesBarChart({
    required List<CalendarData> data,
  }) {
    DateTime startDate = selectedDay.subtract(const Duration(days: 6));
    DateTime endDate = selectedDay;

    DateTime prevStartDate = startDate.subtract(const Duration(days: 7));
    DateTime prevEndDate = endDate.subtract(const Duration(days: 7));

    double thisWeekSalesAmount =
        calculateSalesAmount(startDate, endDate, _calendarDayList);
    double prevWeekSalesAmount =
        calculateSalesAmount(prevStartDate, prevEndDate, _calendarDayList);

    int percentageChange =
        ((thisWeekSalesAmount / prevWeekSalesAmount) * 100 - 100).toInt();
    // Color textColor = prevWeekSalesAmount < thisWeekSalesAmount
    //     ? Color(0xFF266EFF)
    //     : Color(0xFFF10000);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최근7일 매출 비교',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${startDate.month}월 ${startDate.day}일 (${_getWeekday(startDate)}) ~ ${endDate.month}월 ${endDate.day}일 (${_getWeekday(endDate)})',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '이번 주 총 ${AppUtil.formatPrice(thisWeekSalesAmount.toInt())}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '전주 대비 $percentageChange%',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin:
                const EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 10.0),
            child: CustomPaint(
              painter: ChartPainter(_chartList),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }
}

class ChartPainter extends CustomPainter {
  var rowCount = 10;
  var colCount = 7;

  var gridWidth = 50.0;
  var gridHeight = 50.0;

  var _width = 0.0;
  var _height = 0.0;

  final List chartList;

  double textScaleFactor = 1.0;

  ChartPainter(this.chartList);

  void _drawBackground(Canvas canvas) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white70
      ..isAntiAlias = true;

    Rect rect = Rect.fromLTWH(0, 0, _width, _height);
    canvas.drawRect(rect, paint);
  }

  void _drawGrid(Canvas canvas) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey
      ..isAntiAlias = true;

    const double leftOffset = 100;
    const double bottomOffset = 10;
    gridHeight = (_height - bottomOffset) / rowCount;
    gridWidth = (_width - leftOffset) / colCount;

    double maxY = 0;
    if (chartList.isNotEmpty) {
      maxY = chartList
          .map((data) => [data.salesAmount, data.depositAmount])
          .expand((element) => element)
          .reduce((max, current) => max > current ? max : current);
    }

    if (maxY == 0) {
      maxY = 1000000;
    }

    // Determine the grid top value and interval based on the maximum value
    double gridTop;
    double interval;
    if (maxY > 6000000) {
      interval = 2000000;
    } else if (maxY > 3000000) {
      interval = 1000000;
    } else if (maxY > 2000000) {
      interval = 500000;
    } else if (maxY > 1000000) {
      interval = 250000;
    } else if (maxY > 700000) {
      interval = 200000;
    } else if (maxY > 500000) {
      interval = 100000;
    } else if (maxY > 100000) {
      interval = 50000;
    } else if (maxY > 50000) {
      interval = 10000;
    } else if (maxY > 10000) {
      interval = 5000;
    } else {
      interval = 1000;
    }

    // Calculate the grid top value as the nearest multiple of interval above maxY
    gridTop = (maxY / interval).ceil() * interval;

    // Calculate the number of rows
    rowCount = gridTop ~/ interval;

    gridHeight = (_height - bottomOffset) / rowCount;
    gridWidth = (_width - leftOffset) / colCount;

    final rows = rowCount;
    final cols = colCount;

    int leftText = 0;
    intl.NumberFormat numberFormat = intl.NumberFormat('#,###');

    for (int r = 0; r <= rows; r++) {
      final y = (_height - bottomOffset) - (r * gridHeight);
      final p1 = Offset(leftOffset, y);
      final p2 = Offset(_width, y);

      if (r == 0) {
        paint.color = Colors.red;
      } else {
        paint.color = Colors.grey;
      }

      canvas.drawLine(p1, p2, paint);

      const textStyle = TextStyle(
        color: Colors.grey,
        fontSize: 12,
      );

      String leftTextString;
      if (leftText >= 10000) {
        leftTextString = '${leftText ~/ 10000}만';
      } else {
        leftTextString = numberFormat.format(leftText);
      }

      _drawText(canvas, 50, y, leftTextString, textStyle);

      leftText += interval.round();
    }

    for (int c = 0; c < cols; c++) {
      final x = c * gridWidth + leftOffset;
      // final p1 = Offset(x, 0);
      // final p2 = Offset(x, (_height - bottomOffset));

      if (chartList.length > c) {
        double rectHeight = 0;
        Rect rect;
        if (chartList[c].salesAmount != 0) {
          rectHeight =
              ((_height - bottomOffset) * chartList[c].salesAmount) / gridTop;

          // Create a rectangle
          rect = Rect.fromLTWH(
              x, (_height - bottomOffset) - rectHeight, 16, rectHeight);

          // Draw the rectangle on the canvas
          paint.color = const Color.fromRGBO(0x00, 0x00, 0xF1, 1.0);
          canvas.drawRect(rect, paint);
        }
        if (chartList[c].depositAmount != 0) {
          rectHeight =
              ((_height - bottomOffset) * chartList[c].depositAmount) / gridTop;
          // Create a rectangle
          rect = Rect.fromLTWH(
              x + 18, (_height - bottomOffset) - rectHeight, 16, rectHeight);

          // Draw the rectangle on the canvas
          paint.color = Color.fromRGBO(0x14, 0xB8, 0xA6, 1.0);
          canvas.drawRect(rect, paint);
        }
        const textStyle = TextStyle(
          color: Colors.grey,
          fontSize: 12,
        );

        _drawText(canvas, x + 17, _height, chartList[c].date, textStyle);
      }
    }
  }

  void _drawText(Canvas canvas, centerX, centerY, text, style) {
    final textSpan = TextSpan(
      text: text,
      style: style,
    );

    final textPainter = TextPainter()
      ..text = textSpan
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center
      ..layout();

    final xCenter = (centerX - textPainter.width / 2);
    final yCenter = (centerY - textPainter.height / 2);
    final offset = Offset(xCenter, yCenter);

    textPainter.paint(canvas, offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _width = size.width;
    _height = size.height;

    _drawBackground(canvas);
    _drawGrid(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
