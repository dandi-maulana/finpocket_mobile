class Category {
  final String name;
  final double balance;

  Category({required this.name, required this.balance});

  Map<String, dynamic> toMap() {
    return {'name': name, 'balance': balance};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(name: map['name'], balance: map['balance']);
  }
}
