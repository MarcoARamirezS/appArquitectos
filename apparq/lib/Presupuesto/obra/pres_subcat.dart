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
  List<Map<String, Map<String, String>>> categoriasList = [];
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

      List<Map<String, Map<String, String>>> tempCategoriasList = [];

      for (var row in parsedCSV) {
        if (row.isNotEmpty && row[0] is String && row[0].startsWith('A')) {
          String subcategoria = row[0];
          String nombreSubcategoria = row[1];

          if (subcategoria.length == 3) {
            Map<String, Map<String, String>> categoriaMap = {
              'nombreCategoria': {subcategoria: nombreSubcategoria},
              'subcategorias': {},
            };
            tempCategoriasList.add(categoriaMap);
          } else if (subcategoria.length == 5) {
            String categoriaKey = subcategoria.substring(0, 3);
            for (var categoria in tempCategoriasList) {
              if (categoria['nombreCategoria']!.containsKey(categoriaKey)) {
                categoria['subcategorias']![subcategoria] = nombreSubcategoria;
                break;
              }
            }
          }
        }
      }

      print(tempCategoriasList);

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
        title: Text('Página ${widget.categoriaSeleccionada}'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: categoriasList.length,
          itemBuilder: (context, index) {
            String nombreCategoria = categoriasList[index]['nombreCategoria']!.values.first;
            List<String> subcategorias = categoriasList[index]['subcategorias']!.values.toList();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    nombreCategoria,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subcategorias.map((subcategoria) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      child: Text(subcategoria),
                    );
                  }).toList(),
                ),
                const Divider(),
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

void main() {
  runApp(const MaterialApp(
    home: PresSubcatPage(
      categoriaSeleccionada: 'Categoria',
      subcategoriaSeleccionada: 'Subcategoria',
      opcion: 'Opcion',
    ),
  ));
}
