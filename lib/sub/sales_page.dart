import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import '/common/api_service.dart';
import '/common/app_util.dart';
import '/data/do_sales_daily_last_30days.dart';

typedef PageButtonPressed = void Function(String type);

class SalesApp extends StatefulWidget {
  const SalesApp({super.key});

  @override
  State<SalesApp> createState() => _SalesAppState();
}

class _SalesAppState extends State<SalesApp> {
  final List chartSalesList = List.empty(growable: true);
  List<DOSaleDetail> dailySalesList = List.empty(growable: true);
  bool _isLoading = true; // 로딩 상태를 나타내는 변수
  DOSalesDailyLast30Days? _salesDailyLast30Days;
  late int _pageSelected;
  late int _pageMax;

  static const int _initialDayDiff = 29;

  DateTime _selectedDate = DateTime.now();
  DateTime _thirtyDaysAgo = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      _refresh();
    }
  }

  // 최근 30일 데이터를 필터링하는 함수
  List<DOSaleDetail> filterRecent30Days(List<DOSaleDetail> details) {
    // if (kDebugMode) {
    //   print(
    //       'filterRecent30Days - _selectedDate: $_selectedDate, details.length: ${details.length}');
    //   details.forEach((item) {
    //     print(item.saleDate);
    //   });
    // }

    _thirtyDaysAgo = _selectedDate.subtract(const Duration(days: _initialDayDiff));

    return details.where((detail) {
      DateTime saleDate = DateTime(
        int.parse(detail.saleDate.substring(0, 4)),
        int.parse(detail.saleDate.substring(4, 6)),
        int.parse(detail.saleDate.substring(6, 8)),
      );
      return (saleDate.isAfter(_thirtyDaysAgo) ||
              saleDate.isAtSameMomentAs(_thirtyDaysAgo)) &&
          (saleDate.isBefore(_selectedDate) ||
              saleDate.isAtSameMomentAs(_selectedDate));
    }).toList();
  }

  List<DOSaleDetail> filterCurrentPageDays(
      List<DOSaleDetail> details, int pageSelected) {
    if (kDebugMode) {
      print('filterCurrentPageDays - excute');
    }
    const int itemsPerPage = 6;
    const int initialDayDiff = 29;
    int beginDayDiff = initialDayDiff - (pageSelected * itemsPerPage);
    DateTime beginDay = _selectedDate.subtract(Duration(days: beginDayDiff));
    DateTime endDay = beginDay.add(const Duration(days: 6));

    if (kDebugMode) {
      print(
          '_selectedDate: $_selectedDate, pageSelected: $pageSelected, beginDay: $beginDay, endDay: $endDay');
    }

    return details.where((detail) {
      DateTime saleDate = DateTime(
        int.parse(detail.saleDate.substring(0, 4)),
        int.parse(detail.saleDate.substring(4, 6)),
        int.parse(detail.saleDate.substring(6, 8)),
      );
      return (saleDate.isAfter(beginDay) ||
              saleDate.isAtSameMomentAs(beginDay)) &&
          (saleDate.isBefore(endDay) || saleDate.isAtSameMomentAs(endDay));
    }).toList();
  }

  void _refreshSaleDateList() {
    if (kDebugMode) {
      print('_refreshSaleDateList - excute');
    }
    dailySalesList.clear();
    dailySalesList =
        filterCurrentPageDays(_salesDailyLast30Days!.detail, _pageSelected);

    // if (kDebugMode) {
    //   print('dailySalesList:');
    //   dailySalesList.forEach((item) {
    //     print(item.saleDate);
    //   });
    // }
  }

  // 날짜 포맷팅 함수
  String formatDate(String saleDate, bool isFirst, intl.DateFormat mdyFormat,
      intl.DateFormat dayFormat) {
    DateTime date = DateTime(
      int.parse(saleDate.substring(0, 4)),
      int.parse(saleDate.substring(4, 6)),
      int.parse(saleDate.substring(6, 8)),
    );
    if (isFirst || date.day == 1) {
      return mdyFormat.format(date); // "M/D" 형태로 표시
    } else {
      return dayFormat.format(date); // "D" 형태로 표시
    }
  }

  void _refresh() async {
    if (kDebugMode) {
      print('_refresh - excute');
    }

    _thirtyDaysAgo = _selectedDate.subtract(const Duration(days: _initialDayDiff));

    String startDate = _thirtyDaysAgo.toString().substring(0, 10).replaceAll('-', '');
    String endDate = _selectedDate.toString().substring(0, 10).replaceAll('-', '');

    try {
      TApiResponse response =
          await ApiService.getSalesDailyLast30Days(startDate, endDate);
      // 조회 성공 시 처리
      if (response.code == 200) {
        chartSalesList.clear();

        var data = response.data['data'];
        if (data != null) {
          _salesDailyLast30Days = DOSalesDailyLast30Days.fromJson(data);
          // 최근 30일 데이터 필터링
          List<DOSaleDetail> recentDetails =
              filterRecent30Days(_salesDailyLast30Days!.detail);

          intl.DateFormat mdyFormat = intl.DateFormat('M/d');
          intl.DateFormat dayFormat = intl.DateFormat('d');

          for (int i = 0; i < recentDetails.length; i++) {
            var detail = recentDetails[i];
            String formattedDate =
                formatDate(detail.saleDate, i == 0, mdyFormat, dayFormat);
            chartSalesList.add(ChartSalesData(
                formattedDate,
                detail.storeAmount.toDouble(),
                detail.deliveryAmount.toDouble()));
          }

          int recentDetailsLength = recentDetails.length;
          int itemsPerPage = 6;
          _pageMax = (recentDetailsLength / itemsPerPage).ceil();
          _pageSelected = 0;

          _refreshSaleDateList();
        } else {
          if (kDebugMode) {
            print('getSalesDailyLast30Days - data is null');
          }
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
    }
  }

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('build execute');
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 238, 252, 1.0),
      // appBar: AppBar(
      //   title: Text('매출'),
      // ),
      body: _isLoading // 로딩 상태에 따라 다른 위젯을 표시
          ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : Column(
              children: [
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 220,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            const SizedBox(
                              width: 16,
                            ),
                            const Icon(Icons.calendar_month_outlined),
                            Expanded(
                              child: Text(
                                intl.DateFormat('yyyy년 MM월 dd일')
                                    .format(_selectedDate),
                                textAlign: TextAlign.center, // 텍스트를 가운데 정렬합니다.
                              ),
                            ),
                            IconButton(
                              onPressed: () => _selectDate(context),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              // child: const Text('날짜 선택'),
                            ),
                          ],
                        ),
                      ),
                      // Spacer(),
                      Container(
                        width: 160,
                        height: 50,
                        margin: const EdgeInsets.only(
                          right: 16.0,
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white),
                          color: Colors.white,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.circle,
                              color: Color.fromRGBO(0x26, 0x6E, 0xFF, 1.0),
                              size: 24,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text('매장'),
                            Spacer(),
                            Icon(
                              Icons.circle,
                              color: Color.fromRGBO(0xF8, 0x7F, 0x7F, 1.0),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text('배달'),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // 흰색 배경색 설정
                            borderRadius:
                                BorderRadius.circular(16.0), // 라운드 테두리 설정
                          ),
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 16, top: 16.0, right: 16.0, bottom: 16.0),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '일별 매출 비교',
                                          style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${intl.DateFormat('M/d(E)', 'ko_KR').format(_thirtyDaysAgo)} ~ ${intl.DateFormat('M/d(E)', 'ko_KR').format(_selectedDate)}',
                                          style: TextStyle(
                                              fontSize: 10, ),
                                        ),
                                      ],
                                    ),
                                    Expanded(child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '최근 30일간 매출 ${AppUtil.formatPrice(_salesDailyLast30Days!.detailSum)}',
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '전월 대비',
                                          style: TextStyle(
                                            fontSize: 10, ),
                                        ),
                                      ],
                                    ),),
                              ],),),

                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
                                  child: CustomPaint(
                                    painter: ChartSalesPainter(
                                        chartSalesList, _selectedDate),
                                    child: Container(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // 흰색 배경색 설정
                            borderRadius:
                                BorderRadius.circular(16.0), // 라운드 테두리 설정
                          ),
                          margin: const EdgeInsets.all(8.0),
                          // padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              _buildHeaderRow(),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 30,
                                      child: Column(
                                        children: [
                                          _buildListItem(dailySalesList),
                                        ],
                                      ),
                                    ),
                                    // const Expanded(flex: 1, child: Placeholder()),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 16.0,
                                            top: 16.0,
                                            bottom: 16.0,
                                            right: 16.0),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              0x1C, 0x1C, 0x1E, 1.0),
                                          borderRadius: BorderRadius.circular(
                                              24.0), // 라운드 테두리 설정
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.arrow_upward),
                                              color: Colors.white,
                                              onPressed: () {
                                                if (_pageSelected > 0) {
                                                  setState(() {
                                                    _pageSelected--;
                                                    if (kDebugMode) {
                                                      print(
                                                          '_pageSelected: $_pageSelected');
                                                    }
                                                    _refreshSaleDateList();
                                                  });
                                                }
                                                if (kDebugMode) {
                                                  print(
                                                      'Navigation - Prev button pressed');
                                                }
                                              },
                                            ),
                                            Text(
                                              '${_pageSelected + 1}/$_pageMax',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              color: Colors.white, // 아이콘 색상 변경
                                              onPressed: () {
                                                if (_pageSelected <
                                                    (_pageMax - 1)) {
                                                  setState(() {
                                                    _pageSelected++;
                                                    if (kDebugMode) {
                                                      print(
                                                          '_pageSelected: $_pageSelected');
                                                    }
                                                    _refreshSaleDateList();
                                                  });
                                                }
                                                if (kDebugMode) {
                                                  print(
                                                      'Navigation - Next button pressed');
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
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
    );
  }
}

class SalesData {
  final String day;
  final double amount;

  SalesData(this.day, this.amount);
}

Widget _buildHeaderRow() {
  return Container(
    height: 39,
    decoration: const BoxDecoration(
      color: Color.fromRGBO(0xCC, 0xCC, 0xFC, 1.0),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildColumnHeader('날짜'),
        _buildColumnHeader('전체매출'),
        _buildColumnHeader('매장매출'),
        _buildColumnHeader('배달매출'),
        _buildColumnHeader('매장점유율'),
        _buildColumnHeader('배달점유율'),
        _buildColumnHeader('매장건수'),
        _buildColumnHeader('배달건수'),
        // _buildColumnHeader(''),
      ],
    ),
  );
}

Widget _buildListItem(List<DOSaleDetail> detail) {
  return Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int i = 0; i < 6; i++)
          if (detail.length > i) _buildRowItem(detail[i]),
      ],
    ),
  );
}

Widget _buildRowItem(DOSaleDetail saleDetail) {
  String getWeekday(DateTime date) {
    // 요일을 가져와서 해당하는 문자열을 반환합니다.
    switch (date.weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  Widget buildExpandedText(String text, {TextAlign align = TextAlign.right}) {
    return Expanded(
      flex: 1,
      child: Text(text, textAlign: align),
    );
  }

  DateTime date = DateTime.parse(saleDetail.saleDate);
  String formattedDate = '${date.month}/${date.day}(${getWeekday(date)})';

  return Expanded(
    flex: 1,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildExpandedText(formattedDate, align: TextAlign.center),
        buildExpandedText(AppUtil.formatPrice(saleDetail.totalAmount)),
        buildExpandedText(AppUtil.formatPrice(saleDetail.storeAmount)),
        buildExpandedText(AppUtil.formatPrice(saleDetail.deliveryAmount)),
        buildExpandedText('${saleDetail.storeRate}%'),
        buildExpandedText('${saleDetail.deliveryRate}%'),
        buildExpandedText('${saleDetail.storeQuantity}건'),
        buildExpandedText('${saleDetail.deliveryQuantity}건'),
      ],
    ),
  );
}

Widget _buildColumnHeader(String text) {
  return Expanded(
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

class ChartSalesData {
  final String date;
  final double dineInAmount;
  final double deliveryAmount;

  ChartSalesData(this.date, this.dineInAmount, this.deliveryAmount);
}

class ChartSalesPainter extends CustomPainter {
  final List chartSalesList;
  final DateTime selectedDate;

  var rowCount = 10;
  var colCount = 31;

  var gridWidth = 50.0;
  var gridHeight = 50.0;

  var _width = 0.0;
  var _height = 0.0;

  double textScaleFactor = 1.0;

  ChartSalesPainter(this.chartSalesList, this.selectedDate);

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

    const double leftOffset = 80;
    const double bottomOffset = 20;
    gridHeight = (_height - bottomOffset) / rowCount;
    gridWidth = (_width - leftOffset) / chartSalesList.length;

    // ChartSalesData(this.date, this.dineInAmount, this.deliveryAmount);

    double maxY = 0;
    if (chartSalesList.isNotEmpty) {
      maxY = chartSalesList
          .map((data) => data.dineInAmount + data.deliveryAmount)
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
    // final cols = colCount;

    int leftText = 0;
    intl.NumberFormat numberFormat = intl.NumberFormat('#,###');

    for (int r = 0; r <= rows; r++) {
      final y = (_height - bottomOffset) - (r * gridHeight);
      final p1 = Offset(leftOffset, y);
      final p2 = Offset(_width, y);

      paint.color = Colors.grey;
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

    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 12,
    );
    DateTime nodeDate = selectedDate.subtract(const Duration(days: 29));
    String nodeText = '';
    for (int c = 0; c < 30; c++) {
      if (c == 0 || nodeDate.day == 1) {
        nodeText = '${nodeDate.month}/${nodeDate.day}';
      } else {
        nodeText = '${nodeDate.day}';
      }
      _drawText(
          canvas, c * gridWidth + leftOffset + 8, _height, nodeText, textStyle);
      nodeDate = nodeDate.add(const Duration(days: 1));
    }

    for (int c = 0; c < chartSalesList.length; c++) {
      final x = c * gridWidth + leftOffset;
      // final p1 = Offset(x, 0);
      // final p2 = Offset(x, (_height - bottomOffset));

      double rectHeightDinein = 0;
      double rectHeightDelivery = 0;
      Rect rect;

      if (chartSalesList[c].dineInAmount != 0 ||
          chartSalesList[c].deliveryAmount != 0) {
        if (chartSalesList[c].dineInAmount != 0) {
          rectHeightDinein =
              ((_height - bottomOffset) * chartSalesList[c].dineInAmount) /
                  gridTop;
          rect = Rect.fromLTWH(x, (_height - bottomOffset) - rectHeightDinein,
              16, rectHeightDinein);

          // Draw the rectangle on the canvas
          paint.color = c == (chartSalesList.length - 1)
              ? const Color.fromRGBO(0x7F, 0x7F, 0xF8, 1.0)
              : const Color.fromRGBO(0xCC, 0xCC, 0xFC, 1.0);
          // ? const Color.fromRGBO(0x26, 0x6E, 0xFF, 1.0)
          // : const Color.fromRGBO(0x93, 0xB7, 0xFF, 1.0);
          canvas.drawRect(rect, paint);
        }

        if (chartSalesList[c].deliveryAmount != 0) {
          rectHeightDelivery =
              ((_height - bottomOffset) * chartSalesList[c].deliveryAmount) /
                  gridTop;
          rect = Rect.fromLTWH(
              x,
              ((_height - bottomOffset) -
                  rectHeightDelivery -
                  rectHeightDinein +
                  10),
              16,
              rectHeightDelivery - 10);

          // Draw the rectangle on the canvas
          paint.color = c == (chartSalesList.length - 1)
              ? const Color.fromRGBO(0xFF, 0x6E, 0x26, 1.0)
              : const Color.fromRGBO(0xFF, 0xB7, 0x93, 1.0);
          canvas.drawRect(rect, paint);
        }
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
    // _drawNodes(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
