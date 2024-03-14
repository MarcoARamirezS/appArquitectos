import 'package:flutter/material.dart';
import 'publica.dart';

class ObraPage extends StatelessWidget {
  const ObraPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obra'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Qué tipo de obra es?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => PublicaPage()),
                 );
              },
              child: const Text('Pública'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Acción cuando se presiona el botón "Privada"
              },
              child: const Text('Privada'),
            ),
          ],
        ),
      ),
    );
  }
}
