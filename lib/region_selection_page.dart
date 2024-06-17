import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';

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
                        bool isSelected = selectedRegion == '$regionNumber';
                        Color buttonColor = isSelected ? const Color(0xFF044C70) : const Color(0xFFEEEEEE);
                        Color textColor = isSelected ? Colors.white : Colors.black;

                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              displayedRegion = '$regionNumber';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          child: Text(
                            'REGIÓN $regionNumber',
                            style: TextStyle(color: textColor),
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
                      _showSelectionDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF044C70),
                    ),
                    child: const Text(
                      'Seleccionar Región',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Región $selectedRegion Seleccionada'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cambiar'),
            ),
            TextButton(
              onPressed: () async {
                await _saveRegion();
                Navigator.of(context).pop();
                MenuPage.menuPageKey.currentState?.openDrawer();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }
}