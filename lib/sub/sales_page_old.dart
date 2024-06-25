import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesApp extends StatelessWidget {
  const SalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 238, 252, 1.0),
      appBar: AppBar(
        title: Text('매출'),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            child: Row(
              children: [
                Container(
                  width: 300, // 월 선택 위젯의 너비 설정
                  // padding: EdgeInsets.all(16.0), // 각 구역의 패딩 설정
                  color: Colors.yellow, // 첫 번째 구역 배경색 설정
                  // child: MonthPicker(
                  //   onChanged: (selectedMonth) {
                  //     // 선택된 월에 대한 처리
                  //   },
                  // ),
                ),
                Expanded(
                  child: Container(
                    // margin: EdgeInsets.all(16.0),
                    // 첫 번째 구역 Margin 설정
                    color: Colors.blue,
                    // 첫 번째 구역 배경색 설정

                    // 첫 번째 구역 높이 설정
                    // padding: EdgeInsets.all(16.0),
                    // 각 구역의 패딩 설정
                    child: Center(child: Text('첫 번째 구역')), // 첫 번째 구역 텍스트 중앙 정렬
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // _buildRoundedContainer(context, '두 번째 구역'), // 두 번째 구역 위젯 호출
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 배경색 설정
                    borderRadius: BorderRadius.circular(16.0), // 라운드 테두리 설정
                  ),
                  margin: EdgeInsets.all(16.0),
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '일별 매출 비교',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      _buildChart(),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // 흰색 배경색 설정
                      borderRadius: BorderRadius.circular(16.0), // 라운드 테두리 설정
                    ),
                    margin: EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildHeaderRow(),
                        _buildListItem(),
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

  Widget _buildChart() {
    List<SalesData> chartData = [
      SalesData('1일', 10),
      SalesData('2일', 50),
      SalesData('3일', 30),
      SalesData('4일', 80),
      SalesData('5일', 60),
    ];

    return Expanded(
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          ColumnSeries<SalesData, String>(
            dataSource: chartData,
            xValueMapper: (SalesData sales, _) => sales.day,
            yValueMapper: (SalesData sales, _) => sales.amount,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
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
    color: Colors.grey[300],
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildColumnHeader('날짜'),
        _buildColumnHeader('전체매출'),
        _buildColumnHeader('매장매출'),
        _buildColumnHeader('배달매출'),
        _buildColumnHeader('매장점유율'),
        _buildColumnHeader('배달점유율'),
      ],
    ),
  );
}

Widget _buildListItem() {
  return Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int i = 1; i <= 6; i++)
          _buildRowItem(),
      ],
    ),
  );
}

Widget _buildRowItem() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text('2024-04-01'), // 임의의 데이터
      Text('\$1000'), // 임의의 데이터
      Text('\$700'), // 임의의 데이터
      Text('\$300'), // 임의의 데이터
      Text('70%'), // 임의의 데이터
      Text('30%'), // 임의의 데이터
    ],
  );
}

Widget _buildColumnHeader(String text) {
  return Expanded(
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildNavigationButtons() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_upward),
        onPressed: () {
          // 위로 이동 버튼 동작
        },
      ),
      Text('1/10'), // 현재/전체 페이지 정보
      IconButton(
        icon: const Icon(Icons.arrow_downward),
        onPressed: () {
          // 아래로 이동 버튼 동작
        },
      ),
    ],
  );
}
