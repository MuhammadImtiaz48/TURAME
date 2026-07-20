enum WithdrawalMethod { mtnMobile, airtelMoney }

class WithdrawalRecord {
  final String id;
  final String userId;
  final String userRole;
  final double amount;
  final WithdrawalMethod method;
  final DateTime createdAt;
  final String status;

  const WithdrawalRecord({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.amount,
    required this.method,
    required this.createdAt,
    this.status = 'completed',
  });

  factory WithdrawalRecord.fromMap(Map<String, dynamic> map, String id) {
    return WithdrawalRecord(
      id: id,
      userId: map['userId']?.toString() ?? '',
      userRole: map['userRole']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      method: WithdrawalMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => WithdrawalMethod.mtnMobile,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'] is int
                  ? map['createdAt'] as int
                  : int.tryParse(map['createdAt'].toString()) ?? 0,
            )
          : DateTime.now(),
      status: map['status']?.toString() ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userRole': userRole,
        'amount': amount,
        'method': method.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status,
      };

  String get methodLabel {
    switch (method) {
      case WithdrawalMethod.mtnMobile:
        return 'MTN Mobile Money';
      case WithdrawalMethod.airtelMoney:
        return 'Airtel Money';
    }
  }
}
