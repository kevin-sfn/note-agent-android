import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import '/common/api_service.dart';
import '/common/app_util.dart';
import '/data/do_items_analysis_rank.dart';
import '/data/do_items_analysis_rank_last_30days.dart';

class ItemsApp extends StatefulWidget {
  const ItemsApp({super.key});

  @override
  State<ItemsApp> createState() => _ItemsAppState();
}

class _ItemsAppState extends State<ItemsApp> {
  DateTime _selectedDate = DateTime.now();
  final intl.DateFormat _dateFormat = intl.DateFormat('yy.M.d');
  // static const storage = FlutterSecureStorage();
  DOItemsAnalysisRank? _itemsAnalysisRank;
  DOItemsAnalysisRankLast30Days? _itemsAnalysisRankLast30Days;
  int _maxItemPercentage = 0;
  bool _isLoading = true;
  String _modeSelected = "all";

  void _calcMaxItemPercentage() {
    _maxItemPercentage = 0;
    if (_itemsAnalysisRankLast30Days?.itemRankList != null) {
      for (var item in _itemsAnalysisRankLast30Days!.itemRankList) {
        if (_maxItemPercentage < item.rate) {
          _maxItemPercentage = item.rate;
        }
      }
    }

    if (kDebugMode) {
      print('_maxItemPercentage: $_maxItemPercentage');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _refresh();
      });
    }
  }

  void _refresh() async {
    if (kDebugMode) {
      print('_refresh - excute');
    }

    String startDate = _selectedDate
        .subtract(const Duration(days: 29))
        .toString()
        .substring(0, 10)
        .replaceAll('-', '');
    String endDate =
        _selectedDate.toString().substring(0, 10).replaceAll('-', '');
    String type = 'ALL'; // ALL, STORE_SALES, DELIVERY_SALES

    try {
      TApiResponse response =
          await ApiService.getAnalysisItemRank(endDate, endDate, type);
      // 조회 성공 시 처리
      if (response.code == 200) {
        if (_itemsAnalysisRank != null) {
          _itemsAnalysisRank!.itemRankList.clear();
        }

        var data = response.data['data'];
        if (data != null) {
          _itemsAnalysisRank = DOItemsAnalysisRank.fromJson(data);

          // if (kDebugMode) {
          //   for (var item in _itemsAnalysisRank!.itemRankList) {
          //     print(
          //         'itemName: ${item.itemName}, quantity: ${item.quantity}, amount: ${item.amount}');
          //   }
          // }
        } else {
          if (kDebugMode) {
            print('getAnalysisItemRank - data is null');
          }
        }
      }

      response = await ApiService.getAnalysisItemRankLast30Days(
          startDate, endDate, type);
      // 조회 성공 시 처리
      if (response.code == 200) {
        if (_itemsAnalysisRankLast30Days != null) {
          _itemsAnalysisRankLast30Days!.itemRankList.clear();
        }

        var data = response.data['data'];
        if (data != null) {
          _itemsAnalysisRankLast30Days =
              DOItemsAnalysisRankLast30Days.fromJson(data);
          // if (kDebugMode) {
          //   for (var item in _itemsAnalysisRankLast30Days!.itemRankList) {
          //     print(
          //         'itemName: ${item.itemName}, quantity: ${item.quantity}, rate: ${item.rate}');
          //   }
          // }
        } else {
          if (kDebugMode) {
            print('getAnalysisItemRankLast30Days - data is null');
          }
        }
      }

      _calcMaxItemPercentage();

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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 238, 252, 1.0),
      // appBar: AppBar(
      //   title: const Text('메뉴'),
      // ),
      body: _isLoading // 로딩 상태에 따라 다른 위젯을 표시
          ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 220,
                        height: 45,
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
                    ),
                    const Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    // Expanded(
                    //   flex: 2,
                    //   child: Container(
                    //     height: 50,
                    //     decoration: const BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(16.0),
                    //         bottomLeft: Radius.circular(16.0),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 420,
                        height: 45,
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          // border: Border.all(color: Colors.white),
                          color: Color.fromRGBO(237, 238, 252, 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(top: 1, bottom: 1,),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    bottomLeft: Radius.circular(16.0),
                                  ),
                                  // border: Border.all(color: Colors.white),
                                  color: (_modeSelected == "all"
                                      ? const Color.fromRGBO(0, 0, 0xF1, 1.0)
                                      : Colors.white),
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _modeSelected = "all";
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          color: Color.fromRGBO(
                                              0x7F, 0x7F, 0xF8, 1.0),
                                          size: 24,
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          '전체',
                                          style: TextStyle(
                                            color: (_modeSelected == "all"
                                                ? Colors.white
                                                : Colors.black),
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(left: 1,),
                                decoration: BoxDecoration(
                                  color: (_modeSelected == "dine-in"
                                      ? const Color.fromRGBO(0, 0, 0xF1, 1.0)
                                      : Colors.white),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _modeSelected = "dine-in";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        color: Color.fromRGBO(
                                            0x14, 0xB8, 0xA6, 1.0),
                                        size: 24,
                                      ),
                                      SizedBox(width: 8,),
                                      Text(
                                        '매장',
                                        style: TextStyle(
                                          color: (_modeSelected == "dine-in"
                                              ? Colors.white
                                              : Colors.black),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(left: 1,),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16.0),
                                    bottomRight: Radius.circular(16.0),
                                  ),
                                  color: (_modeSelected == "delivery"
                                      ? const Color.fromRGBO(0, 0, 0xF1, 1.0)
                                      : Colors.white),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _modeSelected = "delivery";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        color: Color.fromRGBO(
                                            0xFF, 0x6E, 0x26, 1.0),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8,),
                                      Text(
                                        '배달',
                                        style: TextStyle(
                                          color: (_modeSelected == "delivery"
                                              ? Colors.white
                                              : Colors.black),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          '오늘 메뉴 총 매출',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            '${_itemsAnalysisRank?.totalQuantity ?? 0}건'),
                                      ],
                                    ),
                                    Text(
                                      AppUtil.formatPrice(
                                          _itemsAnalysisRank?.totalAmount ?? 0),
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color:
                                    const Color.fromRGBO(0xED, 0xEE, 0xFC, 1.0),
                                height: 43,
                                margin:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: const Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          '순위',
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 8,
                                        child: Text(
                                          '상품명',
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Text(
                                          '건수',
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Text(
                                          '매출액',
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                              ),
                              if (_itemsAnalysisRank != null)
                                for (int i = 0;
                                    i < _itemsAnalysisRank!.itemRankList.length;
                                    i++)
                                  Expanded(
                                    child: _buildRowItem(
                                        rank: i + 1,
                                        itemName: _itemsAnalysisRank!
                                            .itemRankList[i].itemName,
                                        itemCount: _itemsAnalysisRank!
                                            .itemRankList[i].quantity,
                                        salesAmount: _itemsAnalysisRank!
                                            .itemRankList[i].amount),
                                  ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.only(left: 8, top: 8),
                          margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    '최근 30일 메뉴별 점유율',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('(건수 기준)'),
                                ],
                              ),
                              SizedBox(
                                height: 24,
                                child: Row(
                                  children: [
                                    Text(
                                      '${_dateFormat.format(_selectedDate.subtract(const Duration(days: 29)))} ~ ${_dateFormat.format(_selectedDate)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              if (_itemsAnalysisRankLast30Days != null)
                                for (int i = 0; i < _itemsAnalysisRankLast30Days!.itemRankList.length; i++)
                                  Expanded(
                                    child: _buildPercentageItem(
                                      rank: i + 1,
                                      itemName: _itemsAnalysisRankLast30Days!.itemRankList[i].itemName,
                                      itemCount: _itemsAnalysisRankLast30Days!.itemRankList[i].quantity,
                                      percentage: _itemsAnalysisRankLast30Days!.itemRankList[i].rate
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

  Widget _buildRowItem({
    required int rank,
    required String itemName,
    required int itemCount,
    required int salesAmount,
  }) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
        ),
        Expanded(
            flex: 1,
            child: Text(
              '$rank위',
              textAlign: TextAlign.center,
            )),
        Expanded(
            flex: 8,
            child: Text(
              itemName,
              textAlign: TextAlign.left,
            )),
        Expanded(
            flex: 3,
            child: Text(
              '$itemCount건',
              textAlign: TextAlign.right,
            )),
        Expanded(
            flex: 3,
            child: Text(
              AppUtil.formatPrice(salesAmount),
              textAlign: TextAlign.right,
            )),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget _buildPercentageItem({
    required int rank,
    required String itemName,
    required int itemCount,
    required int percentage,
  }) {
    return Container(
      // padding: const EdgeInsets.only(left: 6.0),
      // margin: EdgeInsets.all(3.0),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.white),
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
      child: Row(
        children: [
          Expanded(
            flex: 15, // 비율에 맞게 설정
            child: _buildRankWidget(rank),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 65, // 비율에 맞게 설정
            child: _buildProductInfoWidget(itemName, percentage),
          ),
          Expanded(
            flex: 20, // 비율에 맞게 설정
            child: _buildSalesCountWidget(itemCount),
          ),
        ],
      ),
    );
  }

  Widget _buildRankWidget(int rank) {
    return Container(
      padding: const EdgeInsets.only(left: 5.0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(0xF5, 0xF5, 0xF5, 1.0),
      ),
      child: Text(
        '$rank위',
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromRGBO(0, 0, 0xF1, 1.0),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProductInfoWidget(String itemName, int percentage) {
    // final double parentWidth = MediaQuery.of(context).size.width * 0.5;
    // final double barWidth = (percentage / 100) * parentWidth;
    final double parentWidth = MediaQuery.of(context).size.width * 0.110;
    final double barWidth = parentWidth.toDouble() * (percentage.toDouble()/_maxItemPercentage.toDouble());
    if (kDebugMode) {
      print('_buildProductInfoWidget - parentWidth: $parentWidth, percentage: $percentage, barWidth: $barWidth');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(itemName, style: TextStyle(fontSize: 11),),
        // SizedBox(height: 5.0),
        Row(
          children: [
            Container(
              width: barWidth,
              height: 5.0,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0x7F, 0x7F, 0xF8, 1.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(
              '${percentage.toString()}%',
              style:
                  const TextStyle(color: Color.fromRGBO(0x7F, 0x7F, 0xF8, 1.0), ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesCountWidget(int itemCount) {
    return Text(
      '$itemCount건',
      textAlign: TextAlign.right,
    );
  }
}
