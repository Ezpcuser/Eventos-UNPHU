import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí puedes usar datos reales más adelante
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Total de Usuarios: 25'),
            SizedBox(height: 10),
            Text('Eventos Activos: 10'),
            SizedBox(height: 10),
            Text('Eventos Finalizados: 5'),
          ],
        ),
      ),
    );
  }
}
