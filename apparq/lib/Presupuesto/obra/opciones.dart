import 'package:flutter/material.dart';
import 'categorias.dart';

class OpcionesPage extends StatelessWidget {
  final String categoriaSeleccionada;

  const OpcionesPage({super.key, required this.categoriaSeleccionada});

  @override
  Widget build(BuildContext context) {
    List<String> opciones = categorias
        .firstWhere((categoria) => categoria.titulo == categoriaSeleccionada)
        .opciones;

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
              children: opciones.map((opcion) {
                return ElevatedButton(
                  onPressed: () {
                    // Acción cuando se selecciona una opción
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
