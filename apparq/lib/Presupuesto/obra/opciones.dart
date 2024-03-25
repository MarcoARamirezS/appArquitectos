import 'package:flutter/material.dart';
import 'categorias.dart';
import 'opciones_subcat.dart';

class OpcionesPage extends StatelessWidget {
  final String categoriaSeleccionada;

  const OpcionesPage({super.key, required this.categoriaSeleccionada});

  @override
  Widget build(BuildContext context) {
    List<Subcategoria> subcategorias = categorias
        .firstWhere((categoria) => categoria.titulo == categoriaSeleccionada)
        .subcategorias;

    return Scaffold(
      appBar: AppBar(
        title: Text('Página $categoriaSeleccionada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Clase $categoriaSeleccionada:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0), // Agregar un padding abajo
                child: SingleChildScrollView(
                  child: Column(
                    children: subcategorias.map((subcategoria) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 350,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OpcionesSubcatPage(
                                      categoriaSeleccionada: categoriaSeleccionada,
                                      subcategoriaSeleccionada: subcategoria.titulo,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xEEEEEEEE),
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                              ),
                              child: Text(
                                subcategoria.titulo,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}