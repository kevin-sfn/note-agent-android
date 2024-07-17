import 'package:flutter/material.dart';
import 'package:note_agent_flutter/sub/purchase_page.dart';
import 'package:note_agent_flutter/sub/settlement_page.dart';
import 'package:note_agent_flutter/sub/sales_page.dart';
import 'package:note_agent_flutter/sub/items_page.dart';
import 'package:note_agent_flutter/sub/dashboard_page.dart';
import 'package:note_agent_flutter/sub/delivery_page.dart';
import 'package:note_agent_flutter/sub/config_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> with SingleTickerProviderStateMixin {
  TabController? controller;
  String? id;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        // title: const Text('차별화상회'),
        elevation: 0, // 하단 경계선 제거
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.0), // 원하는 높이로 설정
          child: TabBar(
            tabs: <Tab>[
              _buildTab(
                icon: Icons.home,
                text: '홈',
              ),
              _buildTab(
                icon: Icons.supervised_user_circle,
                text: '매출',
              ),
              _buildTab(
                icon: Icons.gif_box_outlined,
                text: '메뉴',
              ),
              _buildTab(
                icon: Icons.delivery_dining,
                text: '배달',
              ),
              _buildTab(
                icon: Icons.input_outlined,
                text: '입금',
              ),
              _buildTab(
                icon: Icons.event,
                text: '발주',
              ),
              _buildTab(
                icon: Icons.settings,
                text: '설정',
              ),
            ],
            labelColor: Colors.white, // 선택된 탭 텍스트 색상
            unselectedLabelColor: Colors.black, // 선택되지 않은 탭 텍스트 색상
            labelStyle: TextStyle(fontSize: 16.0), // 선택된 탭 텍스트 폰트 크기
            unselectedLabelStyle: TextStyle(fontSize: 16.0), // 선택되지 않은 탭 텍스트 폰트 크기
            // indicatorColor: Colors.indigoAccent,
            indicator: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0xF1, 1.0), // 선택된 탭의 배경색
              borderRadius: BorderRadius.all(Radius.circular(50)), // 반원 형태
            ),
            controller: controller,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0), // margin 설정
            overlayColor: WidgetStateProperty.all(Colors.transparent), // 탭 버튼 터치 효과 제거
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent), // TabBarView의 테두리 제거
        ),
        child: TabBarView(
          controller: controller,
          children: const <Widget>[
            DashboardApp(),
            SalesApp(),
            ItemsApp(),
            DeliveryApp(),
            SettlementApp(),
            PurchaseApp(),
            ConfigApp(),
          ],
        ),
      ),
    );
  }

  Tab _buildTab({required IconData icon, required String text}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(icon),
          // const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
