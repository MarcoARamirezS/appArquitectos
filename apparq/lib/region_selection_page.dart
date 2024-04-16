import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';
import 'dashboard.dart';

Color region1 = const Color.fromRGBO(243, 236, 199, 1.0);
Color region2 = const Color.fromRGBO(255, 233, 157, 1.0);
Color region3 = const Color.fromRGBO(153, 217, 234, 1.0);
Color region4 = const Color.fromRGBO(211, 240, 123, 1.0);
Color region5 = const Color.fromRGBO(255, 159, 207, 1.0);
Color region6 = const Color.fromRGBO(255, 247, 85, 1.0);
Color region7 = const Color.fromRGBO(228, 197, 228, 1.0);
Color region8 = const Color.fromRGBO(255, 160, 98, 1.0);

class RegionSelectionPage extends StatefulWidget {
  const RegionSelectionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String selectedRegion = '1'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  Future<void> _saveRegion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_region', selectedRegion);
  }

  Future<void> _loadRegion() async {
    final prefs = await SharedPreferences.getInstance();
    String? region = prefs.getString('selected_region');
    if (region != null) {
      setState(() {
        selectedRegion = region;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            SizedBox(
              width: screenSize.width,
              height: screenSize.height * 0.5,
              child: SvgPicture.asset(
                'assets/guanajuato.svg',
                semanticsLabel: 'Mapa de Guanajuato',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedRegion,
              icon: const Icon(Icons.arrow_drop_down_sharp),
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.grey,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedRegion = newValue;
                  });
                }
              },
              items: <String>['1', '2', '3', '4', '5', '6', '7', '8']
                .map<DropdownMenuItem<String>>((String value) {
                Color bgColor;
                switch (value) {
                  case '1':
                    bgColor = region1;
                    break;
                  case '2':
                    bgColor = region2;
                    break;
                  case '3':
                    bgColor = region3;
                    break;
                  case '4':
                    bgColor = region4;
                    break;
                  case '5':
                    bgColor = region5;
                    break;
                  case '6':
                    bgColor = region6;
                    break;
                  case '7':
                    bgColor = region7;
                    break;
                  case '8':
                    bgColor = region8;
                    break;
                  default:
                    bgColor = Colors.white;
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    color: bgColor,
                    child: Text(
                      'Región $value',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveRegion();
                if (MenuPage.menuPageKey.currentState != null) {
                  MenuPage.menuPageKey.currentState!.setPage(DashboardPage(), 'Dashboard');
                } 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 76, 112, 1),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
              ),
              child: const Text(
                'Seleccionar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
