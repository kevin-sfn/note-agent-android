import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// String baseUrl = "https://agent-api-dev.note.chabyulhwa.com";
String baseUrl = "https://agent-api.note.chabyulhwa.com";

class TApiResponse {
  final int code;
  final Map<String, dynamic> data;

  TApiResponse(this.code, this.data);
}

class ApiService {
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(
      String loginId, String loginPw, String appType) async {
    var url = '$baseUrl/oauth/login';

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'loginId': loginId,
        'password': loginPw,
        'appType': appType,
      }),
    );

    if (response.statusCode == 200) {
      var decodedData = utf8.decode(response.bodyBytes);
      var responseData = jsonDecode(decodedData);
      return responseData;
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> oauthPinEnabled() async {
    String accessToken = (await storage.read(key: 'access_token')).toString();
    String oauthAccessToken = (await storage.read(key: 'oauth_access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    var url =
        '$baseUrl/oauth/pin/enabled';

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'accessToken': oauthAccessToken,
        'storeId': storeId,
      }),
    );

    if (response.statusCode == 200) {
      var decodedData = utf8.decode(response.bodyBytes);
      var responseData = jsonDecode(decodedData);
      return responseData;
    } else {
      throw Exception(
          'Failed to oauthPinEnabled: (${response.statusCode}) ${response.reasonPhrase}');
    }
  }

  static Future<TApiResponse> getSalesPayment(String salesDate) async {
    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url = "$baseUrl/dashboard/sales-payment?storeId=$storeId&salesDate=$salesDate";

    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getSalesPayment: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getSalesDeposit(String startDate, String endDate) async {
    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/dashboard/sales-deposit?storeId=$storeId&startDate=$startDate&endDate=$endDate";

    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getSalesDeposit: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getPosScrapingTime(String posCode) async {
    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url = "$baseUrl/pos/scraping-time?storeId=$storeId&posCode=$posCode";

    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200 || response.statusCode == 500) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getPosScrapingTime: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getSalesDailyLast30Days(
      String startDate, String endDate) async {

    if (kDebugMode) {
      print('getSalesDailyLast30Days - startDate: $startDate, endDate: $endDate');
    }

    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/analysis/sales/daily/last-30-days?storeId=$storeId&startDate=$startDate&endDate=$endDate";
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getSalesDailyLast30Days: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getAnalysisItemRank(
      String startDate, String endDate, String type) async {

    if (kDebugMode) {
      print('getAnalysisItemRank - startDate: $startDate, endDate: $endDate, type: $type');
    }

    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/analysis/item/rank?storeId=$storeId&startDate=$startDate&endDate=$endDate&type=$type";
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getAnalysisItemRank: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getAnalysisItemRankLast30Days(
      String startDate, String endDate, String type) async {

    if (kDebugMode) {
      print('getAnalysisItemRank - startDate: $startDate, endDate: $endDate, type: $type');
    }

    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/analysis/item/rank/last-30-days?storeId=$storeId&startDate=$startDate&endDate=$endDate&type=$type";
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getAnalysisItemRank: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getAnalysisDeliverySales(
      String startDate, String endDate) async {

    if (kDebugMode) {
      print('getAnalysisDeliverySales - startDate: $startDate, endDate: $endDate');
    }

    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/analysis/delivery/sales?storeId=$storeId&startDate=$startDate&endDate=$endDate";
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getAnalysisDeliverySales: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getAnalysisSettlementDeposit(
      String date) async {

    if (kDebugMode) {
      print('getAnalysisSettlementDeposit - date: $date');
    }

    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/analysis/settlement/deposit?storeId=$storeId&date=$date";
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getAnalysisSettlementDeposit: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }

  static Future<TApiResponse> getAnalysisSettlementDepositMonthly(
      String month) async {

    if (kDebugMode) {
      print('getAnalysisSettlementDepositMonthly - month: $month');
    }

    String accessToken = (await storage.read(key: 'access_token')).toString();
    String value = (await storage.read(key: 'store_id')).toString();
    int storeId = int.parse(value);

    if (accessToken.isEmpty) {
      return TApiResponse(9999, {});
    }

    String url =
        "$baseUrl/analysis/settlement/deposit/monthly?storeId=$storeId&month=$month";
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var decodedData = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(decodedData);

        return TApiResponse(response.statusCode, responseData);
      } else {
        throw Exception(
            'Failed to getAnalysisSettlementDepositMonthly: (${response.statusCode}) ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return TApiResponse(9999, {});
    }
  }
}
