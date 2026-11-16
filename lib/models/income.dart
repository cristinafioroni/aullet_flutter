class Income {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String? description;

  Income({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    this.description,
  });

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
