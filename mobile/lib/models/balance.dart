class BalanceEntry {
  final int fromPerson;
  final String fromPersonName;
  final int toPerson;
  final String toPersonName;
  final double amount;

  const BalanceEntry({
    required this.fromPerson,
    required this.fromPersonName,
    required this.toPerson,
    required this.toPersonName,
    required this.amount,
  });

  factory BalanceEntry.fromJson(Map<String, dynamic> json) {
    return BalanceEntry(
      fromPerson: json['from_person'] as int,
      fromPersonName: json['from_person_name'] as String,
      toPerson: json['to_person'] as int,
      toPersonName: json['to_person_name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class Balance {
  final List<BalanceEntry> entries;

  const Balance({required this.entries});

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      entries: (json['balances'] as List<dynamic>)
          .map((e) => BalanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
