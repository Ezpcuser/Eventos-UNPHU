import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database/event_database.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    String dateKey = _selectedDate.toString().split(' ')[0];
    List<Map<String, dynamic>> events = await EventDatabase.instance
        .getEventsByDate(dateKey);
    setState(() {
      _events = events;
    });
  }

  String getWeekdayAbbreviation(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Lu';
      case 2:
        return 'Ma';
      case 3:
        return 'Mi';
      case 4:
        return 'Ju';
      case 5:
        return 'Vi';
      case 6:
        return 'Sa';
      case 7:
        return 'Do';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('Calendario'),
        actions: const [Icon(Icons.menu), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildHeader(), _buildDayRow(), _buildEventsSection()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
              });
              _loadEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Column(
            children: [
              Text(
                _selectedDate.day.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                getWeekdayAbbreviation(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Marzo ${_selectedDate.year}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
              _loadEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hoy', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow() {
    final List<DateTime> days = List.generate(
      7,
      (index) => _selectedDate.add(Duration(days: index - 3)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(days.length, (index) {
          final day = days[index];
          bool isSelected = day.isAtSameMomentAs(_selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
              _loadEvents();
            },
            child: Column(
              children: [
                Text(
                  getWeekdayAbbreviation(day),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.green.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('Hora', style: TextStyle(color: Colors.grey)),
                ),
                Text('Servicio', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ..._events.map((event) {
            return _buildEventCard(
              time: event['time'],
              endTime: event['endTime'],
              title: event['title'],
              category: event['category'],
              presenter: event['presenter'],
              organizer: event['organizer'],
              color: Colors.white,
            );
          }).toList(),
          if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay eventos para esta fecha'),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String time,
    required String endTime,
    required String title,
    required String category,
    required String presenter,
    required String organizer,
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(endTime, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/30',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(presenter, style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/30',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(organizer, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (color == Colors.white) const Icon(Icons.more_vert),
          ],
        ),
      ),
    );
  }

  void insertSampleEvents() async {
    Map<String, dynamic> event1 = {
      'date': '2025-03-11',
      'time': '15:00',
      'endTime': '17:00',
      'title': 'Evento Java',
      'category': 'Categoria',
      'presenter': 'Presentador',
      'organizer': 'Organizador',
    };
    Map<String, dynamic> event2 = {
      'date': '2025-03-11',
      'time': '18:00',
      'endTime': '20:00',
      'title': 'Evento Python',
      'category': 'Categoria',
      'presenter': 'Presentador',
      'organizer': 'Organizador',
    };
    await EventDatabase.instance.insertEvent(event1);
    await EventDatabase.instance.insertEvent(event2);
  }
}
