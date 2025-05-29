class UserProfile {
  String name;
  String phoneNumber;
  String email;
  String vinCode;
  String carModel;
  String carYear;
  List<String> tireHistory;

  UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.vinCode,
    required this.carModel,
    required this.carYear,
    this.tireHistory = const [],
  });

  // Метод для конвертації у Map (для збереження локально або на сервері)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'vinCode': vinCode,
      'carModel': carModel,
      'carYear': carYear,
      'tireHistory': tireHistory,
    };
  }

  // Метод для створення об'єкта з Map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      vinCode: json['vinCode'],
      carModel: json['carModel'],
      carYear: json['carYear'],
      tireHistory: List<String>.from(json['tireHistory'] ?? []),
    );
  }
}

class MaintenanceItem {
  final String name;
  final int intervalKm; // через скільки км потрібно зміну
  final Duration intervalTime; // через який час
  DateTime lastChangeDate;
  int lastOdometer;

  MaintenanceItem({
    required this.name,
    required this.intervalKm,
    required this.intervalTime,
    required this.lastChangeDate,
    required this.lastOdometer,
  });

  DateTime get nextChangeDate => lastChangeDate.add(intervalTime);
  int get nextChangeOdometer => lastOdometer + intervalKm;

  bool isDue(int currentOdometer, DateTime currentDate) {
    return currentOdometer >= nextChangeOdometer || currentDate.isAfter(nextChangeDate);
  }
}

