import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'pres_con_page.dart';

class RegionSelectionPage extends StatefulWidget {
  const RegionSelectionPage({super.key});
  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String selectedRegion = '1'; // Suponiendo que tienes regiones numeradas del 1 al 8

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu región'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenSize.width,
              height: screenSize.height * 0.5, // Ajusta esta proporción según sea necesario
              child: SvgPicture.asset(
                'assets/guanajuato.svg',
                semanticsLabel: 'Mapa de Guanajuato',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedRegion,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue!;
                });
              },
              items: <String>['1', '2', '3', '4', '5', '6', '7', '8']
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
                // Navegar a la siguiente página (pres_con.dart) con la región seleccionada
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  PresConPage(selectedRegion: selectedRegion)),
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