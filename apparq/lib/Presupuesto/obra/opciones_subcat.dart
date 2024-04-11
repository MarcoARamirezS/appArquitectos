import 'package:flutter/material.dart';
import 'categorias.dart';
import 'pres_subcat.dart';

class OpcionesSubcatPage extends StatelessWidget {
  final String categoriaSeleccionada;
  final String subcategoriaSeleccionada;
  final String selectedRegion;

  const OpcionesSubcatPage({super.key, required this.categoriaSeleccionada, required this.subcategoriaSeleccionada, required this.selectedRegion});

  @override
  Widget build(BuildContext context) {
    List<Subcategoria> subcategorias = categorias
        .firstWhere((categoria) => categoria.titulo == categoriaSeleccionada)
        .subcategorias;

    List<String> opciones = subcategorias.firstWhere((subcategoria) => subcategoria.titulo == subcategoriaSeleccionada).opciones;

    return Scaffold(
      appBar: AppBar(
        title: Text('Página $categoriaSeleccionada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$subcategoriaSeleccionada:',
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
                    children: opciones.map((opcion) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 350,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PresSubcatPage(
                                      categoriaSeleccionada: categoriaSeleccionada,
                                      subcategoriaSeleccionada: subcategoriaSeleccionada,
                                      opcion: opcion,
                                      selectedRegion: selectedRegion
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xEEEEEEEE),
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                              ),
                              child: Text(
                                opcion,
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
