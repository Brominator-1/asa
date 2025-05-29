import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MaintenanceCalendarScreen extends StatefulWidget {
  @override
  _MaintenanceCalendarScreenState createState() => _MaintenanceCalendarScreenState();
}

class _MaintenanceCalendarScreenState extends State<MaintenanceCalendarScreen> {
  List<Map<String, dynamic>> maintenanceList = [];
  int odometer = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      odometer = prefs.getInt('odometer') ?? 0;
      maintenanceList = (prefs.getStringList('maintenanceList') ?? [])
          .map((item) => Map<String, dynamic>.from(Uri.parse(item).queryParameters))
          .toList();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('odometer', odometer);
    prefs.setStringList(
      'maintenanceList',
      maintenanceList.map((item) => Uri(queryParameters: item).toString()).toList(),
    );
  }

  void _addMaintenance(String type, int intervalKm, int intervalDays) {
    final nextDate = DateTime.now().add(Duration(days: intervalDays));
    final nextMileage = odometer + intervalKm;

    setState(() {
      maintenanceList.add({
        'type': type,
        'date': DateFormat('yyyy-MM-dd').format(nextDate),
        'mileage': nextMileage.toString(),
        'completed': false.toString(),
      });
    });
    _saveData();
  }

  void _updateOdometer(int newOdometer) {
    setState(() {
      odometer = newOdometer;
    });
    _saveData();
  }

  void _markCompleted(int index) {
    setState(() {
      maintenanceList[index]['completed'] = true.toString();
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Календар замін')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Оновити пробіг (км)'),
              onSubmitted: (value) {
                int newOdometer = int.tryParse(value) ?? odometer;
                _updateOdometer(newOdometer);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _addMaintenance('Заміна масла', 10000, 365),
            child: Text('Додати заміну масла'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: maintenanceList.length,
              itemBuilder: (context, index) {
                final item = maintenanceList[index];
                return ListTile(
                  title: Text(item['type']),
                  subtitle: Text('Дата: ${item['date']}, Пробіг: ${item['mileage']} км'),
                  trailing: Checkbox(
                    value: item['completed'] == true.toString(),
                    onChanged: (_) => _markCompleted(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
