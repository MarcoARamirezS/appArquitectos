import 'package:flutter/material.dart';
import 'obra/obra.dart';

class AspectosPage extends StatelessWidget {
  const AspectosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona el Aspecto'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Acción cuando se presiona el botón de Proyecto
              },
              child: const Text('Proyecto'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const ObraPage()),
                 );
              },
              child: const Text('Obra'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción cuando se presiona el botón de Trámite
              },
              child: const Text('Trámite'),
            ),
          ],
        ),
      ),
    );
  }
}