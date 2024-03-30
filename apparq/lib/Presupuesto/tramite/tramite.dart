//Este archivo solo es de pruebas, no tiene nada que ver con el proyecto
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:convert';

class CSVReaderPage extends StatefulWidget {
  const CSVReaderPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CSVReaderPageState createState() => _CSVReaderPageState();
}

class _CSVReaderPageState extends State<CSVReaderPage> {
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
    final ByteData data = await rootBundle.load('assets/Tab1_2024_Z1.csv');
    final List<int> bytes = data.buffer.asUint8List();
    final String csvString = utf8.decode(bytes);
    List<List<dynamic>> parsedCSV = const CsvToListConverter().convert(csvString);
    setState(() {
      csvData = parsedCSV;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSV Reader'),
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