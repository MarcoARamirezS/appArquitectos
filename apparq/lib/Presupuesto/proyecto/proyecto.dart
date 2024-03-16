import 'package:flutter/material.dart';
import 'aspectoProyecto.dart';

class ProyectoPage extends StatefulWidget {
  const ProyectoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProyectoPageState createState() => _ProyectoPageState();
}

class _ProyectoPageState extends State<ProyectoPage> {
  int _menuIndex = 0;
  Map<String, List<String>> selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    final aspecto = aspectosProyecto[_menuIndex];
    List<String> selected = selectedOptions.containsKey(aspecto.titulo)
        ? selectedOptions[aspecto.titulo]!
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyecto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Que alcances tendrá:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildMenu(),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: aspecto.subtitulos.length,
                itemBuilder: (context, index) {
                  final option = aspecto.subtitulos[index];
                  bool isSelected = selected.contains(option);

                  return ListTile(
                    title: Text(option),
                    leading: isSelected ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selected.remove(option);
                        } else {
                          selected.add(option);
                        }
                        selectedOptions[aspecto.titulo] = selected;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 76, 112, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  ),
                  child: const Text(
                    'Accion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return SizedBox(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: aspectosProyecto.length,
        itemBuilder: (context, index) {
          final aspecto = aspectosProyecto[index];
          bool isSelected = index == _menuIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _menuIndex = index;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isSelected ? Colors.blue : Colors.grey,
                ),
              ),
              child: Text(
                aspecto.titulo,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
