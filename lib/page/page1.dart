import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database/event_database.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    // Modificar para obtener la fecha actual
    DateTime now = DateTime.now();
    String monthYear = DateFormat('MMMM y').format(now);
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int firstWeekdayOfMonth = DateTime(now.year, now.month, 1).weekday;
    List<int> eventDays = [11, 14];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bienvenido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Calendario
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthYear,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      ['LU', 'MA', 'MI', 'JU', 'VI', 'SA', 'DO']
                          .map(
                            (e) => Text(
                              e,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: daysInMonth + firstWeekdayOfMonth - 1,
                  itemBuilder: (context, index) {
                    if (index < firstWeekdayOfMonth - 1) {
                      return const SizedBox();
                    }
                    int day = index - firstWeekdayOfMonth + 2;
                    return TextButton(
                      onPressed: () {
                        // Aquí puedes agregar la lógica después de hacer clic en la fecha.
                        print('Hice clic dias $day');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            day == now.day ? Colors.green : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                color:
                                    day == now.day
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                          if (eventDays.contains(day))
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Eventos Próximos
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Eventos Próximos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildEventCard(
                  context,
                  1, // 假设这是事件的 ID
                  'Hackaton Universitario',
                  '18:00PM - 20:00',
                  'Sala Max Henrique',
                ),
                const SizedBox(height: 8),
                _buildEventCard(
                  context,
                  2, // 假设这是事件的 ID
                  'Feria de emprendimiento',
                  '20:00PM - 22:00',
                  'Auditorio',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    int eventId,
    String title,
    String time,
    String location,
  ) {
    return TextButton(
      onPressed: () async {
        // 检查是否可以报名
        bool canRegister = await EventDatabase.instance.canRegisterForEvent(
          eventId,
        );
        if (canRegister) {
          // 增加已报名人数
          await EventDatabase.instance.incrementParticipantCount(eventId);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('报名成功')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('该事件已达到报名人数上限')));
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(time, style: const TextStyle(fontSize: 14)),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 16,
                      ),
                      Text(location, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
