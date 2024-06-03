import 'package:flutter/material.dart';
import 'obra/categorias.dart';
import '../menu.dart';
import 'obra/pres_subcat.dart';

class PresupuestoPage extends StatefulWidget {
  const PresupuestoPage({super.key});

  @override
  _PresupuestoPageState createState() => _PresupuestoPageState();
}

class _PresupuestoPageState extends State<PresupuestoPage> {
  String selectedOption = 'Todos los Tipos de Obra';
  final List<String> options = ['Todos los Tipos de Obra', 'Pública', 'Privada'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.125, vertical: 20.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Selecciona el tipo de obra',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: selectedOption,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedOption = newValue;
                  });
                }
              },
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          if (selectedOption == 'Pública' || selectedOption == 'Todos los Tipos de Obra')
            ExpansionTile(
              iconColor: const Color(0xFF044C70),
              collapsedIconColor: const Color(0xFF044C70),
              title: const Text('Pública', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              children: categorias.map((categoria) {
                return ExpansionTile(
                  iconColor: const Color(0xFF044C70),
                  collapsedIconColor: const Color(0xFF044C70),
                  backgroundColor: const Color.fromARGB(255, 179, 180, 181),
                  collapsedBackgroundColor: const Color.fromARGB(255, 179, 180, 181),
                  title: Text(categoria.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
                  children: categoria.subcategorias.map((subcategoria) {
                    return ExpansionTile(
                      iconColor: const Color(0xFF044C70),
                      collapsedIconColor: const Color(0xFF044C70),
                      backgroundColor: const Color(0xEEEEEEEE),
                      collapsedBackgroundColor: const Color(0xEEEEEEEE),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(subcategoria.titulo, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                      ),
                      children: subcategoria.opciones.map((opcion) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!)
                            )
                          ),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Text(opcion),
                            ),
                            onTap: () {
                              if (MenuPage.menuPageKey.currentState != null) {
                                MenuPage.menuPageKey.currentState!.setPage(
                                  PresSubcatPage(
                                    categoriaSeleccionada: categoria.titulo,
                                    subcategoriaSeleccionada: subcategoria.titulo,
                                    opcion: opcion,
                                  ),
                                  opcion
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          if (selectedOption == 'Privada' || selectedOption == 'Todos los Tipos de Obra')
            const ExpansionTile(
              title: Text('Privada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              children: <Widget>[
                // Inserta aquí tus subopciones para 'Privada'
              ],
            ),
        ],
      ),
    );
  }
}
