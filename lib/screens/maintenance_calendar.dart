import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MaintenanceCalendar extends StatefulWidget {
  const MaintenanceCalendar({super.key});

  @override
  _MaintenanceCalendarState createState() => _MaintenanceCalendarState();
}

class _MaintenanceCalendarState extends State<MaintenanceCalendar> {
  Map<DateTime, List<String>> _events = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final List<Map<String, dynamic>> serviceTypes = [
    {'label': 'Масло', 'icon': Icons.oil_barrel, 'color': Colors.amber},
    {'label': 'Шини', 'icon': Icons.sync, 'color': Colors.blue},
    {'label': 'ТО', 'icon': Icons.build, 'color': Colors.green},
    {'label': 'Фільтр', 'icon': Icons.filter_alt, 'color': Colors.orange},
    {'label': 'Гальм. рідина', 'icon': Icons.opacity, 'color': Colors.red},
    {'label': 'Інше', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      Map<String, dynamic> jsonMap = jsonDecode(eventsString);
      Map<DateTime, List<String>> loadedEvents = {};
      jsonMap.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        List<String> eventList = List<String>.from(value);
        loadedEvents[date] = eventList;
      });
      setState(() {
        _events = loadedEvents;
      });
    }
  }

  void _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> jsonMap = {};
    _events.forEach((key, value) {
      jsonMap[key.toIso8601String()] = value;
    });
    prefs.setString('events', jsonEncode(jsonMap));
  }

  void _addRecord(String record) {
    if (_events[_selectedDay] == null) {
      _events[_selectedDay] = [record];
    } else {
      _events[_selectedDay]!.add(record);
    }
    _saveEvents();
    setState(() {});
  }

  void _showAddEventBottomSheet() {
    String selectedType = '';
    String eventName = '';
    String note = '';
    bool isSTO = false;
    String selectedCar = 'Audi A4';
    int repeatMonths = 6;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тип події', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: serviceTypes.map((type) {
                      final isSelected = selectedType == type['label'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type['icon'], size: 20, color: isSelected ? Colors.white : type['color']),
                            SizedBox(width: 4),
                            Text(type['label']),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            selectedType = type['label'];
                            eventName = type['label'];
                          });
                        },
                        selectedColor: type['color'],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: eventName,
                    decoration: InputDecoration(labelText: 'Назва події'),
                    onChanged: (val) => eventName = val,
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCar,
                    decoration: InputDecoration(labelText: 'Автомобіль'),
                    items: ['Audi A4', 'Tesla Model 3'].map((car) {
                      return DropdownMenuItem(child: Text(car), value: car);
                    }).toList(),
                    onChanged: (val) => selectedCar = val ?? '',
                  ),
                  SizedBox(height: 10),
                  SwitchListTile(
                    title: Text('Обслуговування на СТО'),
                    value: isSTO,
                    onChanged: (val) => setModalState(() => isSTO = val),
                  ),
                  if (isSTO)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Назва або адреса СТО'),
                      ),
                    ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Примітки'),
                    onChanged: (val) => note = val,
                  ),
                  SizedBox(height: 10),
                  Text('Повторювати кожні X місяців'),
                  Slider(
                    value: repeatMonths.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '$repeatMonths',
                    onChanged: (val) => setModalState(() => repeatMonths = val.toInt()),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _addRecord('$eventName (${selectedCar})');
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.save),
                    label: Text('Зберегти подію'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календар ТО'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'uk_UA',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Події на ${DateFormat('dd.MM.yyyy').format(_selectedDay)}:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...(_events[_selectedDay]?.map((event) => ListTile(title: Text(event))) ?? [
                  const ListTile(title: Text('Немає записів')),
                ]),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Найближчі записи:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _getUpcomingEvents(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _getUpcomingEvents() {
    final now = DateTime.now();
    final upcoming = _events.entries
        .where((entry) => entry.key.isAfter(now))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return upcoming.take(5).expand((entry) {
      return entry.value.map((event) {
        return ListTile(
          leading: Icon(Icons.event),
          title: Text(event),
          subtitle: Text(DateFormat('dd.MM.yyyy').format(entry.key)),
        );
      });
    }).toList();
  }

}
