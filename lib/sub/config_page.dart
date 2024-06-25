import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigApp extends StatefulWidget {
  const ConfigApp({super.key});

  @override
  State<ConfigApp> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigApp> {
  bool _isMinimized = true;
  bool _isAutoRun = false;
  int _selectedTransparencyIndex = 0;
  int _selectedIntervalIndex = 0;
  String _selectedMode = 'customer';

  @override
  void initState() {
    super.initState();

    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMinimized = prefs.getBool('isMinimized') ?? true;
      _isAutoRun = prefs.getBool('isAutoRun') ?? false;
      _selectedTransparencyIndex =
          prefs.getInt('selectedTransparencyIndex') ?? 0;
      _selectedIntervalIndex = prefs.getInt('selectedIntervalIndex') ?? 0;
    });
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMinimized', _isMinimized);
    prefs.setBool('isAutoRun', _isAutoRun);
    prefs.setInt('selectedTransparencyIndex', _selectedTransparencyIndex);
    prefs.setInt('selectedIntervalIndex', _selectedIntervalIndex);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다')),
    );
  }

  void _toggleCheckbox() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _toggleCheckboxAutoRun() {
    setState(() {
      _isAutoRun = !_isAutoRun;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0xED, 0xEE, 0xFC, 1.0),
      body: Container(
        margin: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0x7F, 0x7F, 0xF8, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              // padding: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.only(left: 28, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedMode = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 'customer',
                          child: Row(
                            children: [
                              if (_selectedMode == 'customer')
                                const Icon(Icons.check, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text('고객용'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'admin',
                          child: Row(
                            children: [
                              if (_selectedMode == 'admin')
                                const Icon(Icons.check, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text('관리자용'),
                            ],
                          ),
                        ),
                      ];
                    },
                    child: const Row(
                      children: [
                        Text(
                          '설정',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        Text(
                          '로그아웃',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _loadPreferences,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        Text(
                          '새로고침',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _savePreferences,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.save_alt,
                          color: Colors.white,
                        ),
                        Text(
                          '저장',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedMode == "customer"
                  ? buildConfigUser()
                  : buildConfigAdmin(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedButton(int index, String text) {
    bool isSelected = _selectedTransparencyIndex == index;
    return SizedBox(
      width: 100,
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedTransparencyIndex = index;
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildSpeedButtonInterval(int index, String text) {
    bool isSelected = _selectedIntervalIndex == index;
    return SizedBox(
      width: 100,
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedIntervalIndex = index;
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget buildConfigAdmin() { // 안드로이드에서는 COM포트 후킹 등 매출 연동 기능이 없다.
    return const Placeholder();
  }

  Widget buildConfigUser() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 150,
        ),
        Expanded(
          child: Row(
            children: [
              const SizedBox(
                width: 240,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '실행모드',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const Spacer(),
                      ],
                    ),
                    TextButton(
                      onPressed: _toggleCheckbox,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero), // 패딩 제거
                        overlayColor: MaterialStateProperty.all(Colors.transparent), // 눌렸을 때 투명 색상 설정
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            _isMinimized
                                ? 'assets/images/checkbox_checked.png'
                                : 'assets/images/checkbox_unchecked.png',
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text(
                            '최소화 상태로 시작',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Row(
                      children: [
                        Text(
                          '위젯설정',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Spacer(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          '투명도',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 40),
                        _buildSpeedButton(0, "사용안함"),
                        const SizedBox(width: 12),
                        _buildSpeedButton(1, "20%"),
                        const SizedBox(width: 12),
                        _buildSpeedButton(2, "50%"),
                        const SizedBox(width: 12),
                        _buildSpeedButton(3, "80%"),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Row(
                      children: [
                        Text(
                          '프로그램 정보',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Spacer(),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          '버전 1.2.7',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'build 2024.06.13-1',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
