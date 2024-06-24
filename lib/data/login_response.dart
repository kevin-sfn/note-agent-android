class LoginResponse {
  final int enterpriseId; //5913,
  final String enterpriseName; //존쿡 시그니처점,
  final int brandId; //5914,
  final String brandName; //존쿡 시그니처점,
  final int storeId; //5912,
  final String storeName; //존쿡 시그니처점,
  final int employeeId; //5937
  final String accessToken;
  final String access_token;
  final String refresh_token;
  final String token_type;
  final int expires_in;

  // LoginResponse(
  //     this.enterpriseId,
  //     this.enterpriseName,
  //     this.brandId,
  //     this.brandName,
  //     this.storeId,
  //     this.storeName,
  //     this.employeeId,
  //     this.accessToken,
  // );

  LoginResponse({
    required this.enterpriseId,
    required this.enterpriseName,
    required this.brandId,
    required this.brandName,
    required this.storeId,
    required this.storeName,
    required this.employeeId,
    required this.accessToken,
    required this.access_token,
    required this.refresh_token,
    required this.token_type,
    required this.expires_in,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      enterpriseId: json['enterpriseId'],
      enterpriseName: json['enterpriseName'],
      brandId: json['brandId'],
      brandName: json['brandName'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      employeeId: json['employeeId'],
      accessToken: json['accessToken'],
      access_token: json['authToken']['access_token'],
      refresh_token: json['authToken']['refresh_token'],
      token_type: json['authToken']['token_type'],
      expires_in: json['authToken']['expires_in'],
    );
  }
}