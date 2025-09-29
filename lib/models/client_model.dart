class Client {
  int? id;
  String name;
  String lastName;
  String username;
  String password;
  String phone;
  DateTime startDate;
  DateTime endDate;
  int months;
  double price;
  String? referredBy;

  Client({
    this.id,
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.months,
    required this.price,
    this.referredBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'username': username,
      'password': password,
      'phone': phone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'months': months,
      'price': price,
      'referredBy': referredBy,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      lastName: map['lastName'],
      username: map['username'],
      password: map['password'],
      phone: map['phone'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      months: map['months'],
      price: map['price'],
      referredBy: map['referredBy'],
    );
  }
}
