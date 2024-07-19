import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/foundation.dart';
import '/component/sf_table_calendar.dart';
import '/common/api_service.dart';
import '/common/app_util.dart';
import '/data/do_settlement_analysis_deposit.dart';

class SettlementApp extends StatefulWidget {
  const SettlementApp({super.key});

  @override
  State<SettlementApp> createState() => _SettlementAppState();
}

class _SettlementAppState extends State<SettlementApp> {
  DateTime _selectedDate = DateTime.now();
  DOSettlementAnalysisDeposit? _settlementAnalysisDeposit;
  bool _isLoading = true;
  DOMonthlyDeposit? _monthlyDepositPrev;
  DOMonthlyDeposit? _monthlyDeposit;

  final List calendarDayList = List.empty(growable: true);

  DateTime calendarSelectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime calendarFocusedDay = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      calendarFocusedDay = picked;
      _refresh();
    }
  }

  String comparePrevMonth(double val, double valPrev, Text textWidget) {
    String labelCaption;

    if (valPrev == val || valPrev == 0) {
      labelCaption = "---";
    } else {
      int percentageChange = ((val / valPrev) * 100 - 100).toInt();
      labelCaption = "${percentageChange >= 0 ? '+' : '-'}$percentageChange%";
    }

    return labelCaption;
  }

  void _refresh() async {
    if (kDebugMode) {
      print('_refresh - excute');
    }

    String date = _selectedDate.toString().replaceAll('-', '').substring(0, 8);
    String month = _selectedDate.toString().replaceAll('-', '').substring(0, 6);
    String monthPrev = (_selectedDate.month == 1
            ? DateTime(_selectedDate.year - 1, 12, 1)
            : DateTime(_selectedDate.year, _selectedDate.month - 1, 1))
        .toString()
        .replaceAll('-', '')
        .substring(0, 6);
    try {
      TApiResponse response =
          await ApiService.getAnalysisSettlementDeposit(date);
      // 조회 성공 시 처리
      if (response.code == 200) {
        if (_settlementAnalysisDeposit != null) {
          _settlementAnalysisDeposit!.cardDepositList.clear();
          _settlementAnalysisDeposit!.deliveryDepositList.clear();
        }

        var data = response.data['data'];
        if (data != null) {
          _settlementAnalysisDeposit =
              DOSettlementAnalysisDeposit.fromJson(data);

          if (kDebugMode) {
            for (var item in _settlementAnalysisDeposit!.cardDepositList) {
              print(
                  'channelTypeName: ${item.cardCompanyName}, salesCount: ${item.salesCount}, salesAmount: ${item.salesAmount}, feeAmount: ${item.feeAmount}, depositAmount: ${item.depositAmount}');
            }
          }
        } else {
          if (kDebugMode) {
            print('getAnalysisSettlementDeposit - data is null');
          }
        }
      }

      response = await ApiService.getAnalysisSettlementDepositMonthly(month);
      // 조회 성공 시 처리
      if (response.code == 200) {
        var data = response.data['data'];
        if (data != null) {
          _monthlyDeposit = DOMonthlyDeposit.fromJson(data);

          if (kDebugMode) {
            print(
                'month - saleAmount: ${_monthlyDeposit?.saleAmount}, saleCount: ${_monthlyDeposit?.saleCount}, feeAmount: ${_monthlyDeposit?.feeAmount}, depositAmount: ${_monthlyDeposit?.depositAmount}');
          }
        } else {
          if (kDebugMode) {
            print('getAnalysisSettlementDepositMonthly - data is null');
          }
        }
      }

      response =
          await ApiService.getAnalysisSettlementDepositMonthly(monthPrev);
      // 조회 성공 시 처리
      if (response.code == 200) {
        var data = response.data['data'];
        if (data != null) {
          _monthlyDepositPrev = DOMonthlyDeposit.fromJson(data);

          if (kDebugMode) {
            print(
                'monthPrev - saleAmount: ${_monthlyDepositPrev?.saleAmount}, saleCount: ${_monthlyDepositPrev?.saleCount}, feeAmount: ${_monthlyDepositPrev?.feeAmount}, depositAmount: ${_monthlyDepositPrev?.depositAmount}');
          }
        } else {
          if (kDebugMode) {
            print('getAnalysisSettlementDepositMonthly - data is null');
          }
        }
      }

      DateTime startDate =
          DateTime(calendarSelectedDay.year, calendarSelectedDay.month, 1)
              .subtract(const Duration(days: 14));

      // 종료일 계산: 이번 달의 마지막 날부터 1주 후
      DateTime endDate = ((calendarSelectedDay.month < 12)
              ? DateTime(
                  calendarSelectedDay.year, calendarSelectedDay.month + 1, 1)
              : DateTime(calendarSelectedDay.year + 1, 1, 1))
          .add(const Duration(days: 7));

      response = await ApiService.getSalesDeposit(
        startDate.toString().substring(0, 10).replaceAll('-', ''),
        endDate.toString().substring(0, 10).replaceAll('-', ''),
      );
      // 조회 성공 시 처리
      if (response.code == 200) {
        calendarDayList.clear();

        var data = response.data['data'];
        if (data is List) {
          for (var item in data) {
            if (kDebugMode) {
              print('getSalesDeposit - data: $item');
            }
            String date = item['date'].toString();
            double salesAmount = item['salesAmount'].toDouble();
            double depositAmount = item['depositAmount'].toDouble();
            calendarDayList.add(CalendarData(date, salesAmount, depositAmount));
          }
        } else {
          if (kDebugMode) {
            print('getSalesDeposit - data: $data');
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

  void onCalendarDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // 선택된 날짜의 상태를 갱신합니다.
    setState(() {
      calendarSelectedDay = selectedDay;
      calendarFocusedDay = focusedDay;
    });
  }

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0xED, 0xEE, 0xFC, 1.0),
      body: _isLoading // 로딩 상태에 따라 다른 위젯을 표시
          ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 220,
                      height: 40,
                      margin: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
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
                              textAlign: TextAlign.center,
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
                    const Spacer(),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: 400,
                          margin: const EdgeInsets.all(8.0),
                          // color: Colors.white,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                  flex: 20,
                                  child: createTransactionWidget()
                              ),
                              Expanded(
                                flex: 35,
                                child: Column(
                                  children: [
                                    buildListHeaderDelivery(),
                                    if (_settlementAnalysisDeposit != null)
                                      for (var deposit in _settlementAnalysisDeposit!.deliveryDepositList)
                                        buildRowItem(
                                            salesCount: deposit.salesCount,
                                            coName: deposit.channelName,
                                            salesAmount: deposit.salesAmount,
                                            costAmount: deposit.feeAmount,
                                            settlementAmount: deposit.depositAmount),
                                  ],
                                ),
                              ),
                          Expanded(flex: 45, child: Column(children: [
                            buildListHeaderCard(),
                              if (_settlementAnalysisDeposit != null)
                                for (var deposit in _settlementAnalysisDeposit!.cardDepositList)
                                  buildRowItem(
                                      salesCount: deposit.salesCount,
                                      coName: deposit.cardCompanyName,
                                      salesAmount: deposit.salesAmount,
                                      costAmount: deposit.feeAmount,
                                      settlementAmount: deposit.depositAmount),],),),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          // height: 200,
                          margin: const EdgeInsets.all(8.0),
                          // color: Colors.white,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding( padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                                child: Text(
                                  intl.DateFormat('yyyy년 MM월',).format(_selectedDate),
                                  style: const TextStyle(fontSize: 18,),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Center(
                                child: Column(
                                  children: <Widget>[
                                    const Text('이 달의 총 입금 금액'),
                                    Text(
                                      AppUtil.formatPrice(
                                          _monthlyDeposit!.depositAmount),
                                      style: const TextStyle(
                                          color: Color.fromRGBO(
                                              0x14, 0xB8, 0xA6, 1.0),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Text('전월 대비'),
                                        _buildMonthlyRateText(
                                            _monthlyDeposit!.depositAmount,
                                            _monthlyDepositPrev!.depositAmount),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        _buildTileItemCount(
                                          val: _monthlyDeposit!.saleCount,
                                          valPrev: _monthlyDepositPrev!.saleCount,
                                          amountLabel: '건수',
                                          percentageLabel: '전월 대비',
                                        ),
                                        const SizedBox(
                                          width: 32,
                                        ),
                                        _buildTileItemPrice(
                                          amountLabel: '매출액',
                                          percentageLabel: '전월 대비',
                                          val: _monthlyDeposit!.saleAmount,
                                          valPrev:
                                              _monthlyDepositPrev!.saleAmount,
                                        ),
                                        const SizedBox(
                                          width: 32,
                                        ),
                                        _buildTileItemPrice(
                                          amountLabel: '비용',
                                          percentageLabel: '전월 대비',
                                          val: _monthlyDeposit!.feeAmount,
                                          valPrev:
                                              _monthlyDepositPrev!.feeAmount,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              Expanded(
                                child: SfTableCalendar(
                                  calendarDayList: calendarDayList,
                                  selectedDay: calendarSelectedDay,
                                  focusedDay: calendarFocusedDay,
                                  onDaySelected: onCalendarDaySelected,
                                  saleVisible: false,
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

  Widget buildTransactionRow(
      String imagePath, String title, int count, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 10,
        ),
        Image.asset(
          imagePath, // 이미지 파일 경로
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title ${count.toString()}건'),
            Text(AppUtil.formatPrice(amount)),
            // '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}원'),
          ],
        ),
      ],
    );
  }

  Widget createTransactionWidget() {
    if (_settlementAnalysisDeposit == null) {
      return Container();
    }

    var totalAmount = _settlementAnalysisDeposit!.totalCardDepositAmount +
        _settlementAnalysisDeposit!.totalDeliveryDepositAmount;
    String date = intl.DateFormat('yyyy.MM.dd').format(_selectedDate);
    int cardCount = _settlementAnalysisDeposit!.cardDepositList
        .fold(0, (sum, item) => sum + item.salesCount);
    int cardAmount = _settlementAnalysisDeposit!.cardDepositList
        .fold(0, (sum, item) => sum + item.salesAmount);
    int deliveryCount = _settlementAnalysisDeposit!.deliveryDepositList
        .fold(0, (sum, item) => sum + item.salesCount);
    int deliveryAmount = _settlementAnalysisDeposit!.deliveryDepositList
        .fold(0, (sum, item) => sum + item.salesAmount);

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$date 총입금',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                AppUtil.formatPrice(totalAmount),
                style: const TextStyle(
                    color: Color.fromRGBO(0x14, 0xB8, 0xA6, 1.0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              // '${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}원',
              // ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                  flex: 5,
                  child: buildTransactionRow(
                      'assets/images/settlement_delivery.png',
                      '배달',
                      deliveryCount,
                      deliveryAmount)),
              Expanded(
                  flex: 5,
                  child: buildTransactionRow(
                      'assets/images/settlement_card.png',
                      '카드',
                      cardCount,
                      cardAmount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildListHeaderDelivery() {
    return Container(
      height: 24,
      color: const Color.fromRGBO(0xED, 0xEE, 0xFC, 1.0),
      margin: const EdgeInsets.only(left: 8, right: 8),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                '배달사',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 1,
              child: Text(
                '건수',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '매출액',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '비용',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '입금 금액',
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }

  Widget buildListHeaderCard() {
    return Container(
      height: 24,
      color: const Color.fromRGBO(0xED, 0xEE, 0xFC, 1.0),
      margin: const EdgeInsets.only(left: 8, right: 8),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                '카드사',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 1,
              child: Text(
                '건수',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '매출액',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '비용',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: 2,
              child: Text(
                '입금 금액',
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }

  // Widget _buildListItemDelivery() {
  //   return Container();
  // }

  Widget _buildMonthlyRateText(int val, int valPrev) {
    String labelCaption = "---";

    if (valPrev != val && valPrev != 0) {
      int percentageChange = ((val / valPrev) * 100 - 100).toInt();
      labelCaption = "${percentageChange >= 0 ? '+' : ''}$percentageChange%";
    }

    Color textColor = val >= valPrev
        ? const Color.fromRGBO(0xFF, 0x3A, 0x00, 1.0)
        : const Color.fromRGBO(0x00, 0x00, 0xF1, 1.0);

    return Text(
      labelCaption,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildRowItem({
    required String coName,
    required int salesCount,
    required int salesAmount,
    required int costAmount,
    required int settlementAmount,
  }) {
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
              flex: 3,
              child: Text(
                coName,
                textAlign: TextAlign.left,
              )),
          Expanded(
              flex: 1,
              child: Text(
                '$salesCount건',
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 2,
              child: Text(
                AppUtil.formatPrice(salesAmount),
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 2,
              child: Text(
                AppUtil.formatPrice(costAmount),
                textAlign: TextAlign.right,
              )),
          Expanded(
              flex: 2,
              child: Text(
                AppUtil.formatPrice(settlementAmount),
                textAlign: TextAlign.right,
              )),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTileItemPrice(
      {required int val,
      required int valPrev,
      required String amountLabel,
      required String percentageLabel}) {
    return Column(
      children: <Widget>[
        Text(amountLabel),
        Text(
          AppUtil.formatPrice(val),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(percentageLabel),
            const SizedBox(
              width: 8,
            ),
            _buildMonthlyRateText(val, valPrev),
            // Text(
            //   '${percentage.toString()}%',
            //   style: TextStyle(
            //     color: percentage < 0 ? Colors.blueAccent : Colors.redAccent,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildTileItemCount(
      {required int val,
      required int valPrev,
      required String amountLabel,
      required String percentageLabel}) {
    return Column(
      children: <Widget>[
        Text(amountLabel),
        Text(
          '${val.toString()}건',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(percentageLabel),
            const SizedBox(
              width: 8,
            ),
            _buildMonthlyRateText(val, valPrev),
            // Text(
            //   '${percentage.toString()}%',
            //   style: TextStyle(
            //     color: percentage < 0 ? Colors.blueAccent : Colors.redAccent,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
