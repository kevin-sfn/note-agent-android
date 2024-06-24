import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'common/api_service.dart';
import 'data/login_response.dart';

import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> with SingleTickerProviderStateMixin {
  double opacity = 0;
  AnimationController? _animationController;
  Animation? _animation;
  TextEditingController? _idTextController;
  TextEditingController? _pwTextController;
  String result = '';
  static const storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();

    // _idTextController?.text = 'johncook0412';
    // _pwTextController?.text = 'john@sfn#1';
    // _idTextController?.text = '123456';
    // _pwTextController?.text = 'afour0712';
    _idTextController?.text = 'sfood1987';
    _pwTextController?.text = 'sfood2294**';

    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _animation =
        Tween<double>(begin: 0, end: pi * 2).animate(_animationController!);
    _animationController!.repeat();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Future<bool> _login() async {
    String? loginId = _idTextController?.text;
    String? loginPw = _pwTextController?.text;

    // String loginId = 'johncook0412';
    // String loginPw = 'john@sfn#1';
    String appType = 'POS_AGENT';

    bool loginResult = false;

    try {
      // ApiService의 login 함수 호출
      Map<String, dynamic> response = await ApiService.login(loginId!, loginPw!, appType);
      // 로그인 성공 시 처리
      print('로그인 성공: $response');
      // TODO: 로그인 성공 시 다음 화면으로 이동
      Map<String, dynamic> jsonData = response;
      var data = jsonData['data'];

      LoginResponse loginResponse = LoginResponse.fromJson(data);

      await storage.write(
          key: 'access_token',
          value: loginResponse.accessToken);
      await storage.write(
          key: 'store_id',
          value: loginResponse.storeId.toString());
      await storage.write(
          key: 'oauth_access_token',
          value: loginResponse.access_token);
      await storage.write(
          key: 'oauth_refresh_token',
          value: loginResponse.refresh_token);

      // print('Response.data: $data');
      print('data.accessToken: ${data['accessToken']}');

      loginResult = true;
    } catch (e) {
      // 로그인 실패 시 처리
      print('로그인 실패: $e');
      // TODO: 로그인 실패 시 오류 메시지를 사용자에게 표시
    }

    return loginResult;
  }

  Future<bool> _enabledPin() async {
    // String loginId = 'johncook0412';
    // String loginPw = 'john@sfn#1';
    // String appType = 'POS_AGENT';

    bool pinResult = false;

    try {
      // ApiService의 login 함수 호출
      Map<String, dynamic> response = await ApiService.oauthPinEnabled();
      // 로그인 성공 시 처리
      print('로그인 성공: $response');
      // TODO: 로그인 성공 시 다음 화면으로 이동
      Map<String, dynamic> jsonData = response;
      var data = jsonData['data'];

      pinResult = true;
    } catch (e) {
      // 로그인 실패 시 처리
      print('enabledPin 실패: $e');
      // TODO: 로그인 실패 시 오류 메시지를 사용자에게 표시
    }

    return pinResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animationController!,
              builder: (context, widget) {
                return Transform.rotate(
                  angle: _animation!.value,
                  child: widget,
                );
              },
              child: const Icon(
                Icons.airplanemode_active,
                color: Colors.deepOrangeAccent,
                size: 64,
              ),
            ),
            const SizedBox(
              // height: 100,
              child: Center(
                child: Text(
                  '차별화장부 pilot',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(seconds: 1),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _idTextController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _pwTextController,
                      obscureText: true,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(result),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                          onPressed: () async {
                            var url = 'https://www.google.com';
                            var response = await http.get(Uri.parse(url));
                            setState(() {
                              result = response.body;
                            });
                            // Navigator.of(context).pushNamed('/sign');
                          },
                          child: const Text('회원가입')),
                      TextButton(
                          onPressed: () async {
                            bool loginOk = await _login();
                            // if (loginOk) {
                              Navigator.of(context).pushReplacementNamed('/main');
                              // _enabledPin();
                            // }
                          },
                          child: const Text('로그인')),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  void makeDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
