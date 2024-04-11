import 'package:flutter/material.dart';
import 'obra/obra.dart';
import 'proyecto/proyecto.dart';
class AspectosPage extends StatelessWidget {
  final String selectedRegion;
  const AspectosPage({super.key, required this.selectedRegion});

  @override
  Widget build(BuildContext context) {

    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(0, 76, 112, 1),
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      minimumSize: const Size(200, 50),
    );

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProyectoPage()),
                );
              },
              style: elevatedButtonStyle,
              child: const Text(
                'Proyecto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ObraPage(selectedRegion: selectedRegion)),
                );
              },
              style: elevatedButtonStyle,
              child: const Text(
                'Obra',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                
              },
              style: elevatedButtonStyle,
              child: const Text(
                'Trámite',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
