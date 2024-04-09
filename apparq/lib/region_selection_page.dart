import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pres_con_page.dart';

class RegionSelectionPage extends StatefulWidget {
  const RegionSelectionPage({super.key});
  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String selectedRegion = '1'; // Región predeterminada

  @override
  Widget build(BuildContext context) {
    // Obtén el tamaño de la pantalla para dimensionar el SVG adecuadamente
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu región'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Asegúrate de que el tamaño del SVG se ajuste bien a la pantalla
            Container(
              width: screenSize.width,
              height: screenSize.height * 0.5, // Ajusta esta proporción según sea necesario
              child: SvgPicture.asset(
                'assets/guanajuato.svg',
                // Ajusta según el tamaño que desees para el SVG
                semanticsLabel: 'Mapa de Guanajuato',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la siguiente página (pres_con.dart) con la región seleccionada
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