import 'package:flutter/material.dart';
import 'obra/categorias.dart';
import '../menu.dart';
import 'obra/pres_subcat.dart';
import 'obra/categorias_privadas.dart';

class PresupuestoPage extends StatefulWidget {
  const PresupuestoPage({super.key});

  @override
  _PresupuestoPageState createState() => _PresupuestoPageState();
}

class _PresupuestoPageState extends State<PresupuestoPage> {
  String selectedOption = 'Pública';
  final List<String> options = ['Pública', 'Privada'];
  String? selectedCategoria;
  String? selectedSubcategoria;
  String? selectedCostoBase;

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
                    selectedCategoria = null;
                    selectedSubcategoria = null; 
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
          if (selectedOption == 'Pública')
            ...categorias.map((categoria) {
              return ExpansionTile(
                iconColor: const Color(0xFF044C70),
                collapsedIconColor: const Color(0xFF044C70),
                title: Text(categoria.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
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
                                opcion,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }),
          if (selectedOption == 'Privada')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: categoriasPrivadas.length,
                    itemBuilder: (BuildContext context, int index) {
                      final categoria = categoriasPrivadas[index];
                      final isSelected = selectedCategoria == categoria.titulo;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoria = categoria.titulo;
                            selectedSubcategoria = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(categoria.imagePath, height: 80),
                              const SizedBox(height: 8.0),
                              Text(
                                categoria.titulo,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Column(
                    children: [
                      const Text(
                        'Tipo de Edificación:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(selectedCategoria != null ? 'Seleccione el tipo de edificación' : 'Selecciona una categoría primero'),
                        value: selectedSubcategoria,
                        items: selectedCategoria == null
                            ? []
                            : categoriasPrivadas
                                .firstWhere((categoria) => categoria.titulo == selectedCategoria!)
                                .subcategorias
                                .asMap()
                                .entries
                                .map<DropdownMenuItem<String>>((entry) {
                              int idx = entry.key;
                              String value = entry.value;
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (idx > 0) const Divider(),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: selectedCategoria == null ? null : (String? newValue) {
                          setState(() {
                            selectedSubcategoria = newValue;
                            print(newValue);
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return selectedCategoria == null
                              ? [const Text('Selecciona una categoría primero')]
                              : categoriasPrivadas
                                  .firstWhere((categoria) => categoria.titulo == selectedCategoria!)
                                  .subcategorias
                                  .map<Widget>((String value) {
                                return Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 80),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Column(
                    children: [
                      const Text(
                        'Costo Base de Referencia:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: const Text('Seleccione la referencia de su costo base'),
                        value: selectedCostoBase,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Costo base calculado',
                            child: Text('Costo base calculado'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Costo base anual',
                            child: Text('Costo base anual'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Costo base actualizado al mes',
                            child: Text('Costo base actualizado al mes'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCostoBase = newValue;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return const [
                            Text('Costo base calculado'),
                            Text('Costo base anual'),
                            Text('Costo base actualizado al mes'),
                          ];
                        },
                      ),
                    ],
                  ),
                  if (selectedCostoBase == null)
                    const SizedBox(height: 150.0),
                  if (selectedCostoBase != null)
                    const SizedBox(height: 20.0),
                  if (selectedCostoBase != null)
                    Column(
                      children: [
                        if (selectedCostoBase == 'Costo base calculado')
                          Column(
                            children: [
                              const Text(
                                'Ingresa tu costo base calculado:',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.attach_money),
                                  hintText: 'Costo base',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        if (selectedCostoBase == 'Costo base anual' || selectedCostoBase == 'Costo base actualizado al mes')
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Acción para editar costos de referencia
                                },
                                child: const Text('Editar costos de referencia'),
                              ),
                              if (selectedCostoBase == 'Costo base actualizado al mes') ...[
                                const SizedBox(height: 20.0),
                                const Text(
                                  'Ingresa el mes:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 10.0),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  hint: const Text('Seleccione el mes'),
                                  items: const [
                                    DropdownMenuItem<String>(
                                      value: 'Enero',
                                      child: Text('Enero'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Febrero',
                                      child: Text('Febrero'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Marzo',
                                      child: Text('Marzo'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Abril',
                                      child: Text('Abril'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Mayo',
                                      child: Text('Mayo'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Junio',
                                      child: Text('Junio'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Julio',
                                      child: Text('Julio'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Agosto',
                                      child: Text('Agosto'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Septiembre',
                                      child: Text('Septiembre'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Octubre',
                                      child: Text('Octubre'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Noviembre',
                                      child: Text('Noviembre'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Diciembre',
                                      child: Text('Diciembre'),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    // Acción al seleccionar un mes
                                  },
                                ),
                              ],
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        const Text(
                          'Ingrese los m² de su proyecto:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          decoration: InputDecoration(
                            suffixText: 'm²',
                            hintText: 'm²',
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: selectedSubcategoria != null &&
                            selectedCostoBase != null &&
                            /* Other conditions to check if required fields are filled */
                            true
                        ? () {
                            print("hola");
                          }
                        : null,
                    child: const Text('Continuar'),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
