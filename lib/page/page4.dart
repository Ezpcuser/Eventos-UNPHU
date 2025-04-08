import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_page.dart'; // Asegúrate de que este import sea correcto para tu proyecto

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Page4> {
  bool _notificationsEnabled = false;

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.green.shade700,
        actions: const [Icon(Icons.menu), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Alex ZL',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Matricula: 25-2025',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.book_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Ingeneria En Sistema Computadoras',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text('Santo Domingo', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.person_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text('az25-2025', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.mail_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text('az25-2025@unphu.edu.do', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.phone_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Text('829-111-2222', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Queria activa la notificacion ?',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _notificationsEnabled = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificaciones activadas')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _notificationsEnabled
                            ? Colors.green
                            : Colors.grey.shade300,
                    foregroundColor:
                        _notificationsEnabled ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Si'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _notificationsEnabled = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones desactivadas'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_notificationsEnabled
                            ? Colors.grey.shade400
                            : Colors.grey.shade300,
                    foregroundColor:
                        !_notificationsEnabled ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('No'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: _cerrarSesion, // Llama a la función _cerrarSesion
                child: const Text(
                  'CERRAR SESIÓN', // Cambiado el texto para mayor claridad
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: QrImageView(
                data:
                    'Alex ZL\nMatricula: 25-2025\nIngeneria En Sistema Computadoras\nSanto Domingo\naz25-2025\naz25-2025@unphu.edu.do\n829-111-2222',
                version: QrVersions.auto,
                size: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
