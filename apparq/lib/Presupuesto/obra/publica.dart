import 'package:flutter/material.dart';
import 'opciones.dart';

class PublicaPage extends StatelessWidget {
  const PublicaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pública'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Clase de constructora:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OpcionesPage(categoriaSeleccionada: 'A'),
                          ),
                        );
                      },
                      child: const Text('A'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OpcionesPage(categoriaSeleccionada: 'B'),
                          ),
                        );
                      },
                      child: const Text('B'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OpcionesPage(categoriaSeleccionada: 'C'),
                          ),
                        );
                      },
                      child: const Text('C'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OpcionesPage(categoriaSeleccionada: 'D'),
                          ),
                        );
                      },
                      child: const Text('D'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OpcionesPage(categoriaSeleccionada: 'E'),
                          ),
                        );
                      },
                      child: const Text('E'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OpcionesPage(categoriaSeleccionada: 'F'),
                          ),
                        );
                      },
                      child: const Text('F'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
