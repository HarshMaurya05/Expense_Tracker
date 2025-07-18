class expenseModel {
  String? title;
  int? amount;
  String? category;
  String? date;
  String? note;
  int? id;

  expenseModel({
    this.title,
    this.amount,
    this.category,
    this.date,
    this.note,
    this.id,
  });

  expenseModel.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    category = json['category']?.toString();
    date = json['date']?.toString();
    note = json['note']?.toString();

    // Safely parse amount and id
    amount = json['amount'] is int
        ? json['amount']
        : int.tryParse(json['amount'].toString());

    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['amount'] = amount;
    data['category'] = category;
    data['date'] = date;
    data['note'] = note;
    data['id'] = id;
    return data;
  }
}
