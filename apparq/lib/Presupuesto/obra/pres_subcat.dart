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
  List<List<dynamic>> csvData = [];

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
      setState(() {
        csvData = parsedCSV;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('CSV Data:'),
            Expanded(
              child: ListView.builder(
                itemCount: csvData.length,
                itemBuilder: (context, index) {
                  List<dynamic> row = csvData[index];
                  return ListTile(
                    title: Text(row.join(', ')), // Mostrar la fila como texto
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String removeAccents(String input) {
  return input.replaceAll('Á', 'A')
              .replaceAll('É', 'E')
              .replaceAll('Í', 'I')
              .replaceAll('Ó', 'O')
              .replaceAll('Ú', 'U');
}