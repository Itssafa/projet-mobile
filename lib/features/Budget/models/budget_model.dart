class Budget {
  int? id;
  double totalBudget;
  double spent;
  String month;

  Budget({
    this.id,
    required this.totalBudget,
    required this.spent,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalBudget': totalBudget,
      'spent': spent,
      'month': month,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      totalBudget: map['totalBudget'],
      spent: map['spent'],
      month: map['month'],
    );
  }
}
