import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:convert';

class PresSubcatPage extends StatefulWidget {
  final String categoriaSeleccionada;
  final String subcategoriaSeleccionada;
  final String opcion;

  const PresSubcatPage({
    super.key,
    required this.categoriaSeleccionada,
    required this.subcategoriaSeleccionada,
    required this.opcion,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PresSubcatPageState createState() => _PresSubcatPageState();
}

class _PresSubcatPageState extends State<PresSubcatPage> {
  List<Categoria> categoriasList = [];
  String? subcategoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
    final subcategoriaMayusculas = removeAccents(widget.subcategoriaSeleccionada.toUpperCase());
    final opcionMayusculas = removeAccents(widget.opcion.toUpperCase());
    String ruta = '${widget.categoriaSeleccionada}/$subcategoriaMayusculas/$opcionMayusculas/archivo.csv';

    try {
      final ByteData data = await rootBundle.load('assets/csv/$ruta');
      final List<int> bytes = data.buffer.asUint8List();
      final String csvString = utf8.decode(bytes);
      List<List<dynamic>> parsedCSV = const CsvToListConverter().convert(csvString);
      List<Categoria> tempCategoriasList = [];
      Categoria? categoriaActual;
      Subcat? subcategoriaActual;

      for (var row in parsedCSV) {
        if (row.isNotEmpty && row[0] is String) {
          final codigo = row[0];

          if (codigo.length == 3) {
            categoriaActual = Categoria(nombre: row[1], subcategorias: []);
            tempCategoriasList.add(categoriaActual);
          } else if (codigo.length == 5 && categoriaActual != null) {
            subcategoriaActual = Subcat(nombre: row[1], productos: []);
            categoriaActual.subcategorias.add(subcategoriaActual);
          } else if (codigo.length > 0 && subcategoriaActual != null && row[1].length > 0) {
            final nombre = row.isNotEmpty ? row[1] : '';
            final unidad = row.isNotEmpty ? row[2] : '';
            final precioString = row.isNotEmpty ? row[3].toString().replaceAll(',', '') : '0'; // Convertir a cadena
            final precio = double.tryParse(precioString) ?? 0;
            print(precioString);
            subcategoriaActual.productos.add(Producto(
              clave: codigo,
              nombre: nombre,
              unidad: unidad,
              precio: precio,
            ));
          }
        }
      }

      setState(() {
        categoriasList = tempCategoriasList;
      });
    } catch (e) {
      print('Error al cargar el archivo CSV: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.opcion),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: categoriasList.length,
          itemBuilder: (context, index) {
            final categoria = categoriasList[index];
            return ExpansionTile( // ExpansionTile para la categoría
              title: Text(categoria.nombre),
              children: [
                // Iterar sobre las subcategorías
                ...categoria.subcategorias.map((subcategoria) => ExpansionTile( // ExpansionTile para la subcategoría
                  title: Text(subcategoria.nombre),
                  children: [
                    // Iterar sobre los productos
                    ...subcategoria.productos.map((producto) => ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text('${producto.unidad} - \$${producto.precio}'),
                    )).toList(),
                  ],
                )).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

String removeAccents(String input) {
  return input
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U');
}

class Categoria {
  final String nombre;
  final List<Subcat> subcategorias;

  Categoria({
    required this.nombre,
    required this.subcategorias,
  });
}

class Subcat {
  final String nombre;
  final List<Producto> productos;

  Subcat({
    required this.nombre,
    required this.productos,
  });
}

class Producto {
  final String clave;
  final String nombre;
  final String unidad;
  final int cantidad;
  final double precio;

  Producto({
    required this.clave,
    required this.nombre,
    required this.unidad,
    required this.precio,
    this.cantidad = 0,
  });
}

void main() {
  runApp(const MaterialApp(
    home: PresSubcatPage(
      categoriaSeleccionada: 'Categoria',
      subcategoriaSeleccionada: 'Subcategoria',
      opcion: 'Opcion',
    ),
  ));
}
