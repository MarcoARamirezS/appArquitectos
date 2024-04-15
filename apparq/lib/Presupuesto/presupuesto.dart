import 'package:flutter/material.dart';
import 'obra/categorias.dart';
import '../menu.dart';
import 'obra/pres_subcat.dart';

class PresupuestoPage extends StatefulWidget {
  const PresupuestoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
                focusedBorder: OutlineInputBorder(
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
          ExpansionTile(
            title: Text('Pública'),
            children: categorias.map((categoria) {
              return ExpansionTile(
                title: Text(categoria.titulo),
                children: categoria.subcategorias.map((subcategoria) {
                  return ExpansionTile(
                    title: Text(subcategoria.titulo),
                    children: subcategoria.opciones.map((opcion) {
                      return ListTile(
                        title: Text(opcion),
                        onTap: () {
                          // Acciones al seleccionar una opción, por ejemplo, navegar a una pantalla de detalles
                          if (MenuPage.menuPageKey.currentState != null) {
                            MenuPage.menuPageKey.currentState!.setPage(PresSubcatPage(
                                      categoriaSeleccionada: categoria.titulo,
                                      subcategoriaSeleccionada: subcategoria.titulo,
                                      opcion: opcion,
                                      ), opcion);
                          } 
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          const ExpansionTile(
            title: Text('Privada'),
            children: <Widget>[
              // Inserta aquí tus subopciones para 'Privada'
            ],
          ),
          // Añade aquí más widgets si necesitas
        ],
      ),
    );
  }
}