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
      // appBar: AppBar(title: Text('차별화상회'),),
      body: TabBarView(
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
      bottomNavigationBar: TabBar(
        tabs: <Tab>[
          _buildTab(icon: Icons.home, text: '홈',),
          _buildTab(icon: Icons.supervised_user_circle, text: '매출',),
          _buildTab(icon: Icons.gif_box_outlined, text: '메뉴',),
          _buildTab(icon: Icons.delivery_dining, text: '배달',),
          _buildTab(icon: Icons.input_outlined, text: '입금',),
          _buildTab(icon: Icons.event, text: '발주',),
          _buildTab(icon: Icons.settings, text: '설정',),
        ],
        labelColor: Colors.indigo,
        indicatorColor: Colors.indigoAccent,
        // indicatorWeight: 6,
        controller: controller,
      ),
    );
  }

  Tab _buildTab({required IconData icon, required String text}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }}