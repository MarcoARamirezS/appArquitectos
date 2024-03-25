import 'package:flutter/material.dart';
import 'aspecto_proyecto.dart';

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
                  _showConfirmationDialog(context);
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
                isSelected ? const Color(0xFF044C70) : const Color(0xFF6C6F72),
              ),
              minimumSize: MaterialStateProperty.all<Size>(
                const Size(150, 50),
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

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Usted ha seleccionado:'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        children: _generateSummaryText(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('¿Desea continuar con estas opciones?'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Lógica para continuar con las opciones
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> _generateSummaryText() {
    List<TextSpan> summaryText = [];
    selectedOptions.forEach((key, value) {
      if (value.isNotEmpty) {
        summaryText.add(TextSpan(text: "$key:\n", style: const TextStyle(fontWeight: FontWeight.bold)));
        for (var option in value) {
          summaryText.add(TextSpan(text: '- $option\n'));
        }
      }
    });
    return summaryText;
  }
}