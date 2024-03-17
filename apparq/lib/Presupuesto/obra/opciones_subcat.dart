import 'package:flutter/material.dart';
import 'categorias.dart';

class OpcionesSubcatPage extends StatelessWidget {
  final String categoriaSeleccionada;
  final String subcategoriaSeleccionada;

  const OpcionesSubcatPage({super.key, required this.categoriaSeleccionada, required this.subcategoriaSeleccionada});

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
            Column(
              children: opciones.map((opcion) {
                return ElevatedButton(
                  onPressed: () {

                  },
                  child: Text(opcion),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
