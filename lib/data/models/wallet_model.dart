class WalletResponse {
  int? statusCode;
  bool? success;
  String? message;
  WalletData? data;

  WalletResponse({this.statusCode, this.success, this.message, this.data});

  WalletResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? WalletData.fromJson(json['data']) : null;
  }
}

class WalletData {
  String? sId;
  String? userId;
  num? balance;
  num? pendingBalance;
  num? totalEarnings;
  num? totalWithdrawn;
  String? currency;
  String? createdAt;
  String? updatedAt;
  EarningsInfo? thisMonthEarnings;
  EarningsInfo? lastMonthEarnings;

  WalletData({ 
    this.sId,
    this.userId,
    this.balance,
    this.pendingBalance,
    this.totalEarnings,
    this.totalWithdrawn,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.thisMonthEarnings,
    this.lastMonthEarnings,
  });

  WalletData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    balance = json['balance'] ?? 0;
    pendingBalance = json['pendingBalance'] ?? 0;
    totalEarnings = json['totalEarnings'] ?? 0;
    totalWithdrawn = json['totalWithdrawn'] ?? 0;
    currency = json['currency'] ?? 'EUR';
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    thisMonthEarnings = json['thisMonthEarnings'] != null
        ? EarningsInfo.fromJson(json['thisMonthEarnings'])
        : null;
    lastMonthEarnings = json['lastMonthEarnings'] != null
        ? EarningsInfo.fromJson(json['lastMonthEarnings'])
        : null;
  }
}

//montly income trend

class EarningsInfo {
  num? amount;
  num? percentageChange;

  EarningsInfo({this.amount, this.percentageChange});

  EarningsInfo.fromJson(Map<String, dynamic> json) {
    amount = json['amount'] ?? 0;
    percentageChange = json['percentageChange'] ?? 0;
  }
}
