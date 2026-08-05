class ExpenseSplit {
  final int memberId;
  final double share;

  const ExpenseSplit({required this.memberId, required this.share});

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      memberId: json['member_id'] as int,
      share: (json['share'] as num).toDouble(),
    );
  }
}

class Expense {
  final int id;
  final double amount;
  final String description;
  final int payerId;
  final String payerName;
  final DateTime date;
  final DateTime createdAt;
  final List<ExpenseSplit> splits;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.payerId,
    required this.payerName,
    required this.date,
    required this.createdAt,
    required this.splits,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      payerId: json['payer_id'] as int,
      payerName: json['payer_name'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      splits: (json['splits'] as List<dynamic>)
          .map((e) => ExpenseSplit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
