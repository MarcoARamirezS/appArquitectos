import 'package:flutter/material.dart';
import 'Presupuesto/aspectos.dart';

class PresConPage extends StatelessWidget {
  const PresConPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuesto y Construcción'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // No hace nada cuando se presiona el botón de "Construcción"
              },
              child: const Text('Construcción'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => AspectosPage()),
                 );
              },
              child: const Text('Presupuesto'),
            ),
          ],
        ),
      ),
    );
  }
}
