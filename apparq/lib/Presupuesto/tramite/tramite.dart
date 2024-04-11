//Este archivo solo es de pruebas, no tiene nada que ver con el proyecto
import 'package:flutter/material.dart';

class CSVReaderPage extends StatefulWidget {
  const CSVReaderPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CSVReaderPageState createState() => _CSVReaderPageState();
}

class _CSVReaderPageState extends State<CSVReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tramites'),
      ),
    );
  }
}