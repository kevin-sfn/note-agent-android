import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import '/common/api_service.dart';
import '/data/do_delivery_analysis_sales.dart';

class DeliveryApp extends StatefulWidget {
  const DeliveryApp({super.key});

  @override
  State<DeliveryApp> createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp> {
  DateTime _selectedDate = DateTime.now();
  DODeliveryAnalysisSales? _deliveryAnalysisSales;
  bool _isLoading = true;

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

    String salesDate = _selectedDate
        .toString()
        .substring(0, 10)
        .replaceAll('-', '');

    try {
      TApiResponse response = await ApiService.getAnalysisDeliverySales(
          salesDate, salesDate);
      // 조회 성공 시 처리
      if (response.code == 200) {
        if (_deliveryAnalysisSales != null) {
          _deliveryAnalysisSales!.deliverySalesList?.clear();
        }

        var data = response.data['data'];
        if (data != null) {
          _deliveryAnalysisSales = DODeliveryAnalysisSales.fromJson(data);

          if (kDebugMode) {
            for (var item in _deliveryAnalysisSales!.deliverySalesList!) {
              print(
                  'channelTypeName: ${item.channelTypeName}, salesCount: ${item.salesCount}, salesAmount: ${item.salesAmount}');
            }
          }
        } else {
          if (kDebugMode) {
            print('getAnalysisDeliverySales - data is null');
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 238, 252, 1.0),
      // appBar: AppBar(
      //   title: const Text('배달'),
      // ),
      body: _isLoading // 로딩 상태에 따라 다른 위젯을 표시
          ? const Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
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
                    const SizedBox(width: 16,),
                    const Icon(Icons.calendar_month_outlined),
                    Expanded(
                      child: Text(intl.DateFormat('yyyy년 MM월 dd일').format(_selectedDate),textAlign: TextAlign.center,),
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
              const Icon(
                Icons.circle,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 4,),
              const Text('매장'),
              const SizedBox(width: 16,),
              const Icon(
                Icons.circle,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 4,),
              const Text('배달'),
              const SizedBox(width: 16,),
            ],
          ),
          Expanded(
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(10.0),
              // color: Colors.white,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
                color: Colors.white,
              ),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        const Text('총 배달 건수'),
                        Text(
                          '${_deliveryAnalysisSales?.totalSalesCount ?? 0}건',
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('전월 일평균 대비'),
                            Text(
                              '${_deliveryAnalysisSales?.rateOfSalesCount ?? 0}%',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildTileItem(
                        amount: _deliveryAnalysisSales?.totalSalesAmount ?? 0,
                        percentage: _deliveryAnalysisSales?.rateOfSalesAmount.toInt() ?? 0,
                        amountLabel: '총 매출 금액',
                        percentageLabel: '전월 일평균 대비',
                      ),
                      const SizedBox(width: 32,),
                      _buildTileItem(
                        amountLabel: '비용',
                        amount: _deliveryAnalysisSales?.totalDeliveryFeeAmount ?? 0,
                        percentageLabel: '전월 일평균 대비',
                        percentage: _deliveryAnalysisSales?.rateOfDeliveryFeeAmount.toInt() ?? 0,
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      _buildTileItem(
                        amountLabel: '정산금액',
                        amount: _deliveryAnalysisSales?.totalDepositAmount ?? 0,
                        percentageLabel: '전월 일평균 대비',
                        percentage: _deliveryAnalysisSales?.rateOfDepositAmount.toInt() ?? 0,
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    margin: const EdgeInsets.all(16.0),
                    // color: Colors.white,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.lightBlueAccent),
                      color: Colors.lightBlueAccent,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(flex: 1, child: Text('순위', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('배달사', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('건수', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('매출액', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('비용', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('정산금액', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('전월 일평균 매출액', textAlign: TextAlign.center,),),
                        Expanded(flex: 1, child: Text('전월 일평균 대비', textAlign: TextAlign.center,),),
                      ],
                    ),
                  ),
                  if (_deliveryAnalysisSales != null)
                    for (int i = 0; i < _deliveryAnalysisSales!.deliverySalesList!.length; i++)
                      _buildRowItem(
                        rank: i + 1,
                        channelTypeName: _deliveryAnalysisSales!.deliverySalesList![i].channelTypeName,
                        salesCount: _deliveryAnalysisSales!.deliverySalesList![i].salesCount,
                        salesAmount: _deliveryAnalysisSales!.deliverySalesList![i].salesAmount,
                        deliveryFeeAmount: _deliveryAnalysisSales!.deliverySalesList![i].deliveryFeeAmount,
                        depositAmount: _deliveryAnalysisSales!.deliverySalesList![i].depositAmount,
                        lastMonthSalesAverage: _deliveryAnalysisSales!.deliverySalesList![i].lastMonthSales.average,
                        lastMonthSalesRate: _deliveryAnalysisSales!.deliverySalesList![i].lastMonthSales.rate,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem({
    required int rank,
    required String channelTypeName,
    required int salesCount,
    required int salesAmount,
    required int deliveryFeeAmount,
    required int depositAmount,
    required int lastMonthSalesAverage,
    required int lastMonthSalesRate,
  }) {
    final formatter = intl.NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 1,
          child: Text(
            '$rank위',
            textAlign: TextAlign.center, // 순위는 가운데 정렬
          ),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 118,
            child: Text(
              channelTypeName,
              textAlign: TextAlign.left, // 배달사는 왼쪽 정렬
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '$salesCount건',
            textAlign: TextAlign.center, // 건수는 가운데 정렬
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            formatter.format(salesAmount),
            textAlign: TextAlign.right, // 매출액은 오른쪽 정렬
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            formatter.format(deliveryFeeAmount),
            textAlign: TextAlign.right, // 비용은 오른쪽 정렬
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            formatter.format(depositAmount),
            textAlign: TextAlign.right, // 정산금액은 오른쪽 정렬
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            formatter.format(lastMonthSalesAverage),
            textAlign: TextAlign.right, // 전월 일평균 매출액은 오른쪽 정렬
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${lastMonthSalesRate.toString()}%',
            textAlign: TextAlign.right, // 전월 일평균 대비는 오른쪽 정렬
            style: TextStyle(
              color: lastMonthSalesRate >= 0 ? Colors.orange : Colors.blue,
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget _buildTileItem(
      {required int amount,
      required int percentage,
      required String amountLabel,
      required String percentageLabel}) {
    final formatter = intl.NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Column(
      children: <Widget>[
        Text(amountLabel),
        Text(
          formatter.format(amount),
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
            Text(
              '${percentage.toString()}%',
              style: TextStyle(
                color: percentage < 0 ? Colors.blueAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
