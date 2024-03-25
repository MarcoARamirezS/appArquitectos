import 'package:flutter/material.dart';
import 'publica.dart';

class ObraPage extends StatelessWidget {
  const ObraPage({super.key});
  @override
  Widget build(BuildContext context) {

    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(0, 76, 112, 1),
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      minimumSize: const Size(170, 50),
    );

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
                   MaterialPageRoute(builder: (context) => const PublicaPage()),
                 );
              },
              style: elevatedButtonStyle,
              child: const Text('Pública',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Acción cuando se presiona el botón "Privada"
              },
              style: elevatedButtonStyle,
              child: const Text('Privada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
