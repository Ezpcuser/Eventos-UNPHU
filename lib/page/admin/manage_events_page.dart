import 'package:flutter/material.dart';
import '../database/event_database.dart';
import 'package:intl/intl.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Eventos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: EventDatabase.instance.getAllEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['title']),
                  subtitle: Text(
                    '${event['date']} ${event['time']} - ${event['endTime']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditEventDialog(context, event);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await EventDatabase.instance.deleteEvent(event['id']);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Evento eliminado')),
                            );
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController presenterController = TextEditingController();
    TextEditingController organizerController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now().replacing(
      hour: (TimeOfDay.now().hour + 1) % 24,
    );

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    Future<void> _selectStartTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: startTime,
      );
      if (picked != null) {
        setState(() {
          startTime = picked;
          if (startTime.hour > endTime.hour ||
              (startTime.hour == endTime.hour &&
                  startTime.minute > endTime.minute)) {
            endTime = startTime.replacing(hour: (startTime.hour + 1) % 24);
          }
        });
      }
    }

    Future<void> _selectEndTime(BuildContext context) async {
      if (startTime == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('请先选择开始时间')));
        }
        return;
      }
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: endTime,
      );
      if (picked != null) {
        if (picked.hour < startTime.hour ||
            (picked.hour == startTime.hour &&
                picked.minute < startTime.minute)) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('结束时间不能早于开始时间')));
          }
          return;
        }
        setState(() {
          endTime = picked;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  'Fecha: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                ),
              ),
              TextButton(
                onPressed: () => _selectStartTime(context),
                child: Text('Hora de inicio: ${startTime.format(context)}'),
              ),
              TextButton(
                onPressed: () => _selectEndTime(context),
                child: Text('Hora de fin: ${endTime.format(context)}'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: presenterController,
                decoration: const InputDecoration(labelText: 'Presentador'),
              ),
              TextField(
                controller: organizerController,
                decoration: const InputDecoration(labelText: 'Organizador'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El título del evento no puede estar vacío',
                        ),
                      ),
                    );
                  }
                  return;
                }
                if (startTime.hour > endTime.hour ||
                    (startTime.hour == endTime.hour &&
                        startTime.minute > endTime.minute)) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La hora de inicio debe ser antes de la hora de fin',
                        ),
                      ),
                    );
                  }
                  return;
                }
                try {
                  Map<String, dynamic> event = {
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'time': startTime.format(context),
                    'endTime': endTime.format(context),
                    'title': titleController.text,
                    'category': categoryController.text,
                    'presenter': presenterController.text,
                    'organizer': organizerController.text,
                    'location': locationController.text,
                    'content': contentController.text,
                    'participantLimit': 0,
                  };
                  await EventDatabase.instance.insertEvent(event);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evento agregado')),
                    );
                  }
                  Navigator.pop(context);
                  setState(() {});
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al agregar evento: $e')),
                    );
                  }
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEventDialog(
    BuildContext context,
    Map<String, dynamic> event,
  ) async {
    TextEditingController titleController = TextEditingController(
      text: event['title'],
    );
    TextEditingController categoryController = TextEditingController(
      text: event['category'],
    );
    TextEditingController presenterController = TextEditingController(
      text: event['presenter'],
    );
    TextEditingController organizerController = TextEditingController(
      text: event['organizer'],
    );
    TextEditingController locationController = TextEditingController(
      text: event['location'],
    );
    TextEditingController contentController = TextEditingController(
      text: event['content'],
    );

    DateTime selectedDate = DateTime.parse(event['date']);

    // 处理时间解析
    TimeOfDay parseTime(String timeStr) {
      try {
        List<String> parts = timeStr.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]); // 去除可能的 AM/PM
        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('时间解析错误: $e')));
        }
        return TimeOfDay.now();
      }
    }

    TimeOfDay startTime = parseTime(event['time']);
    TimeOfDay endTime = parseTime(event['endTime']);

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    Future<void> _selectStartTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: startTime,
      );
      if (picked != null) {
        setState(() {
          startTime = picked;
          if (startTime.hour > endTime.hour ||
              (startTime.hour == endTime.hour &&
                  startTime.minute > endTime.minute)) {
            endTime = startTime.replacing(hour: (startTime.hour + 1) % 24);
          }
        });
      }
    }

    Future<void> _selectEndTime(BuildContext context) async {
      if (startTime == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('请先选择开始时间')));
        }
        return;
      }
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: endTime,
      );
      if (picked != null) {
        if (picked.hour < startTime.hour ||
            (picked.hour == startTime.hour &&
                picked.minute < startTime.minute)) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('结束时间不能早于开始时间')));
          }
          return;
        }
        setState(() {
          endTime = picked;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  'Fecha: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                ),
              ),
              TextButton(
                onPressed: () => _selectStartTime(context),
                child: Text('Hora de inicio: ${startTime.format(context)}'),
              ),
              TextButton(
                onPressed: () => _selectEndTime(context),
                child: Text('Hora de fin: ${endTime.format(context)}'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: presenterController,
                decoration: const InputDecoration(labelText: 'Presentador'),
              ),
              TextField(
                controller: organizerController,
                decoration: const InputDecoration(labelText: 'Organizador'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El título del evento no puede estar vacío',
                        ),
                      ),
                    );
                  }
                  return;
                }
                if (startTime.hour > endTime.hour ||
                    (startTime.hour == endTime.hour &&
                        startTime.minute > endTime.minute)) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La hora de inicio debe ser antes de la hora de fin',
                        ),
                      ),
                    );
                  }
                  return;
                }
                try {
                  Map<String, dynamic> updatedEvent = {
                    'id': event['id'],
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'time': startTime.format(context),
                    'endTime': endTime.format(context),
                    'title': titleController.text,
                    'category': categoryController.text,
                    'presenter': presenterController.text,
                    'organizer': organizerController.text,
                    'location': locationController.text,
                    'content': contentController.text,
                    'participantLimit': event['participantLimit'],
                  };
                  await EventDatabase.instance.updateEvent(updatedEvent);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Evento actualizado')),
                    );
                  }
                  Navigator.pop(context);
                  setState(() {});
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar evento: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
