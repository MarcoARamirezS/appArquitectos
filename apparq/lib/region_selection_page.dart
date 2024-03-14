import 'package:flutter/material.dart';
import 'pres_con_page.dart'; // Asegúrate de importar la siguiente página aquí

class RegionSelectionPage extends StatefulWidget {
  const RegionSelectionPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String selectedRegion = '1'; // Región predeterminada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu región'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedRegion,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue!;
                });
              },
              items: <String>['1', '2', '3', '4', '5', '6', '7', '8'] // Cambia aquí según tus regiones
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('Región $value'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la siguiente página (pres_con.dart)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PresConPage()),
                );
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}

