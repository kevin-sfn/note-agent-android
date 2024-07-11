import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'common/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WebViewController? _webViewController;
  final TextEditingController _controller = TextEditingController();
  String _storeName = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadStoreName();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('https://static.chabyulhwa.com/market/assets/note/pages/lock/index.html'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  Future<void> _loadStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storeName = prefs.getString('store_name') ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _pinValidation() async {
    bool pinResult = false;

    try {
      // ApiService의 login 함수 호출
      Map<String, dynamic> response =
          await ApiService.oauthPinValidation(number: _controller.text);
      // 로그인 성공 시 처리
      print('로그인 성공: $response');
      // TODO: 로그인 성공 시 다음 화면으로 이동
      Map<String, dynamic> jsonData = response;
      var resultCode = jsonData['resultCode'];
      var resultMessage = jsonData['resultMessage'];
      var data = jsonData['data'];

      var pinEnabled = data['pinEnabled'];

      pinResult = true;
    } catch (e) {
      // 로그인 실패 시 처리
      print('enabledPin 실패: $e');
      // TODO: 로그인 실패 시 오류 메시지를 사용자에게 표시+*-
    }

    return pinResult;
  }

  void _onNumPadButtonPressed(String text) {
    if (text == 'C') {
      _controller.clear();
    } else if (text == '<') {
      if (_controller.text.isNotEmpty) {
        _controller.text =
            _controller.text.substring(0, _controller.text.length - 1);
      }
    } else {
      _controller.text += text;
    }
  }

  Widget _buildNumPadButton({required String text}) {
    return Expanded(
      flex: 1,
      child: TextButton(
        onPressed: () {
          _onNumPadButtonPressed(text);
        },
        style: ButtonStyle(
          overlayColor:
              MaterialStateProperty.all(Colors.transparent), // 눌렸을 때 투명 색상 설정
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 라운드 처리 각도
              side: BorderSide(
                  color: Color.fromRGBO(0xBF, 0xBF, 0xBF, 1.0),
                  width: 1.0), // 회색 테두리 적용
            ),
          ),
          fixedSize: MaterialStateProperty.all(Size.fromHeight(55)), // 버튼 높이 설정
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Container(
              width: 630 * 1.2,
              margin:
                  EdgeInsets.only(top: 32.0, left: 32, right: 16, bottom: 32),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 630 * 1.2,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(0x7F, 0x7F, 0xF8, 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      padding: EdgeInsets.all(64),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // 이 부분 추가로 모든 자식을 좌측 정렬
                        children: [
                          Text(
                            _storeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            '서울숲점',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            '오늘 아메리카노가 많이 판매되고 있습니다.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            '준비된 재료가 충분한지 체크해 보세요~!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 630 * 1.2,
                    height: 150 * 1.2,
                    child: WebViewWidget(
                      controller: _webViewController!,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin:
                    EdgeInsets.only(top: 32.0, left: 16, right: 32, bottom: 32),
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 160,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '관리자 비밀번호를\r\n입력해주세요.',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                    TextField(
                      controller: _controller,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(), // 기본 언더라인 설정
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(
                                  0x00, 0x00, 0xF1, 1)), // 포커스 시 언더라인 색상 변경
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32.0),
                      child: Column(
                        children: [
                          for (int row = 0; row < 4; row++)
                            Row(
                              children: [
                                for (int col = 0; col < 3; col++)
                                  _buildNumPadButton(
                                    text: [
                                      ['1', '2', '3'],
                                      ['4', '5', '6'],
                                      ['7', '8', '9'],
                                      ['C', '0', '<'],
                                    ][row][col],
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                      children: [
                        Spacer(),
                        SizedBox(
                          width: 200,
                          height: 60,
                          child: TextButton(
                            onPressed: () async {
                              bool pinOk = await _pinValidation();
                              if (pinOk) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/main');
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("오류"),
                                      content: Text("PIN 번호가 틀렸습니다."),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("확인"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xFF0000F1)), // 배경색 설정
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(50), // 좌측 반원
                                    right: Radius.circular(50), // 우측 반원
                                  ),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all(Colors.white), // 글자색 설정
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue.withOpacity(0.5); // 눌렸을 때의 색상 설정
                                  }
                                  return null; // 다른 상태에서는 기본 색상 사용
                                },
                              ),
                            ),
                            child: const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                    // Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
