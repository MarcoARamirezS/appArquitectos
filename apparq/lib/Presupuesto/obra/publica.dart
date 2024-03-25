import 'package:flutter/material.dart';
import 'opciones.dart';
import 'categorias.dart';

class PublicaPage extends StatelessWidget {
  const PublicaPage({super.key});

  @override
  Widget build(BuildContext context) {

    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xEEEEEEEE),
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      minimumSize: const Size(50, 50),
    );

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
                  children: categorias.sublist(0, 3).map((categoria) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OpcionesPage(categoriaSeleccionada: categoria.titulo),
                              ),
                            );
                          },
                          style: elevatedButtonStyle,
                          child: Text(categoria.titulo,
                            style: const TextStyle(
                             color: Colors.black,
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
                Column(
                  children: categorias.sublist(3, 6).map((categoria) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OpcionesPage(categoriaSeleccionada: categoria.titulo),
                              ),
                            );
                          },
                          style: elevatedButtonStyle,
                          child: Text(categoria.titulo,
                            style: const TextStyle(
                             color: Colors.black,
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
