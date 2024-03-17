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
            Column(
              children: subcategorias.map((subcategoria) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpcionesSubcatPage(categoriaSeleccionada: categoriaSeleccionada, subcategoriaSeleccionada: subcategoria.titulo),
                      ),
                    );
                  },
                  child: Text(subcategoria.titulo),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
