import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'menu.dart';
//import 'dashboard.dart';

Color region1 = const Color.fromRGBO(255, 127, 191, 1.0);
Color region2 = const Color.fromRGBO(145, 81, 165, 1.0);
Color region3 = const Color.fromRGBO(83, 165, 84, 1.0);
Color region4 = const Color.fromRGBO(254, 255, 128, 1.0);
Color region5 = const Color.fromRGBO(83, 144, 165, 1.0);
Color region6 = const Color.fromRGBO(164, 83, 82, 1.0);
Color region7 = const Color.fromRGBO(255, 191, 128, 1.0);
Color region8 = const Color.fromRGBO(190, 255, 128, 1.0);

class RegionSelectionPage extends StatefulWidget {
  const RegionSelectionPage({super.key});

  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String? selectedRegion;
  String? displayedRegion;

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  Future<void> _saveRegion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_region', selectedRegion!);
    setState(() {
      displayedRegion = null;
    });
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

  Color getRegionColor(int regionNumber) {
    switch (regionNumber) {
      case 1:
        return region1;
      case 2:
        return region2;
      case 3:
        return region3;
      case 4:
        return region4;
      case 5:
        return region5;
      case 6:
        return region6;
      case 7:
        return region7;
      case 8:
        return region8;
      default:
        return Colors.white;
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
            SizedBox(height: displayedRegion == null ? 10 : 50),
            SizedBox(
              width: screenSize.width,
              height: screenSize.height * 0.5,
              child: displayedRegion == null
                  ? Image.asset(
                      'assets/mapa/GUANAJUATO.png',
                      fit: BoxFit.contain,
                    )
                  : Stack(
                      children: [
                        Image.asset(
                          'assets/mapa/REGION $displayedRegion.png',
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                displayedRegion = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            Text(
              selectedRegion != null
                  ? displayedRegion != null
                      ? 'Región $displayedRegion'
                      : 'Región seleccionada: $selectedRegion'
                  : 'No hay región seleccionada',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            displayedRegion == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: 8,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3, 
                      ),
                      itemBuilder: (context, index) {
                        int regionNumber = index + 1;
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              displayedRegion = '$regionNumber';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getRegionColor(regionNumber),
                          ),
                          child: Text(
                            'REGIÓN $regionNumber',
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      },
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedRegion = displayedRegion;
                      });
                      _saveRegion();
                      /*if (MenuPage.menuPageKey.currentState != null) {
                        MenuPage.menuPageKey.currentState!.setPage(const DashboardPage(), 'Dashboard');
                      }*/
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getRegionColor(int.parse(displayedRegion!)),
                    ),
                    child: const Text(
                      'Seleccionar Región',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}