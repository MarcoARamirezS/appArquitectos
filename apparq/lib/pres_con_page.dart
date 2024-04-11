import 'package:flutter/material.dart';
import 'Presupuesto/aspectos.dart';

class PresConPage extends StatelessWidget {
  final String selectedRegion;

  const PresConPage({super.key, required this.selectedRegion});
  

  @override
  Widget build(BuildContext context) {
    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(0, 76, 112, 1),
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
    );

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
              style: elevatedButtonStyle,
              child: const Text(
                'Construcción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AspectosPage(selectedRegion: selectedRegion)),
                );
              },
              style: elevatedButtonStyle,
              child: const Text(
                'Presupuesto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
