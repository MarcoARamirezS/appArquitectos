// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api
import 'dart:io';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'obra/categorias.dart';
import '../menu.dart';
import 'obra/pres_subcat.dart';
import 'obra/categorias_privadas.dart';
import 'package:flutter/services.dart';
import 'package:apparq/Presupuesto/obra/factor_de_costo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresupuestoPage extends StatefulWidget {
  const PresupuestoPage({super.key});

  @override
  _PresupuestoPageState createState() => _PresupuestoPageState();
}

class _PresupuestoPageState extends State<PresupuestoPage> {
  String? selectedRegion;
  String selectedOption = 'Pública';
  final List<String> options = ['Pública', 'Privada'];
  String? selectedCategoria;
  String? selectedSubcategoria;
  String? selectedCostoBase;
  String? selectedMes;
  List<TextEditingController> _controllers = [];
  int _numReferences = 2;
  final TextEditingController _inflationController = TextEditingController();
  final TextEditingController _costBaseController = TextEditingController();
  final TextEditingController _m2Controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool highlightEdificationTypeDropdown = false;
  bool highlightCostReferenceDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadRegion();
    _initializeControllers(_numReferences);
  }

  void _initializeControllers(int num) {
    _controllers = List.generate(num, (index) {
      if (index < _costOptions.length) {
        return TextEditingController(text: _costOptions[index]);
      } else {
        return TextEditingController();
      }
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

  final List<String> _costOptions = [
    '2024 - \$9454',
    '2023 - \$9219',
    '2022 - \$7969',
    '2021 - \$7013',
    '2020 - \$6300',
    '2019 - \$8502',
    '2018 - \$7604',
    '2017 - \$7089',
    '2016 - \$6589',
    '2015 - \$6240',
    '2014 - \$6092',
  ];

  final List<String> _inflationOptions = [
    '2024 - 5.17%',
    '2023 - 4.66%',
    '2022 - 7.82%',
    '2021 - 7.36%',
    '2020 - 3.15%',
    '2019 - 2.83%',
    '2018 - 4.83%',
    '2017 - 6.77%',
    '2016 - 3.36%',
    '2015 - 2.13%',
    '2014 - 4.08%',
  ];

  void _showUserGuideDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guía de usuario:'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Costo base calculado:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Elija esta opción si lo que desea es ingresar su propio costo base por metro cuadrado',
                ),
                SizedBox(height: 10),
                Text(
                  '2. Costo base anual:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Elija esta opción si lo que desea es tomar los costos por metro cuadrado de referencia a nivel estatal o ingresar sus propios costos de referencia',
                ),
                SizedBox(height: 10),
                Text(
                  '3. Costo base actualizado al mes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Elija esta opción si lo que desea es tomar los costos por metro cuadrado de referencia a nivel estatal o ingresar sus propios costos de referencia y actualizarlo a un mes en específico',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF044C70),
              ),
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese un valor';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Ingrese un número válido';
    }
    final formatted = number.toStringAsFixed(2);
    if (formatted != value) {
      return 'Ingrese un número con máximo 2 decimales';
    }
    return null;
  }

  void _showEditReferenceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Editar costo base de referencia'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i = 0; i < _numReferences; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Referencia ${i + 1}: Costo por m²',
                                    textAlign: TextAlign.center,
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: _controllers[i].text.isNotEmpty ? _controllers[i].text : null,
                                    items: _costOptions.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _controllers[i].text = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor seleccione un valor';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (i >= 2)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _numReferences--;
                                    _controllers.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    if (_numReferences < 6)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                        ),
                        onPressed: () {
                          setState(() {
                            _numReferences++;
                            _controllers.add(TextEditingController());
                          });
                        },
                        child: const Text('Agregar más referencias'),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Porcentaje de inflación anual', textAlign: TextAlign.center),
                          DropdownButtonFormField<String>(
                            value: _inflationController.text.isNotEmpty ? _inflationController.text : null,
                            items: _inflationOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option.split(' - ')[1],
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _inflationController.text = value!;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor seleccione un valor';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                  ),
                  child: const Text('Guardar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _scrollToEdificationType() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        ).then((_) {
          setState(() {
            highlightEdificationTypeDropdown = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              value: selectedOption,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedOption = newValue;
                    selectedCategoria = null;
                    selectedSubcategoria = null;
                    selectedCostoBase = null;
                    selectedMes = null;
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
                            highlightEdificationTypeDropdown = true;
                          });
                          _scrollToEdificationType();
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
                          fillColor: highlightEdificationTypeDropdown ? Color.fromARGB(255, 210, 234, 253) : Colors.grey[200],
                          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50),
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
                            highlightEdificationTypeDropdown = false;
                            highlightCostReferenceDropdown = true;
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
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Costo Base de Referencia:',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.help_outline),
                            onPressed: _showUserGuideDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: highlightCostReferenceDropdown && selectedCostoBase == null ? const Color.fromARGB(255, 210, 234, 253) : Colors.grey[200],
                          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50),
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
                            highlightCostReferenceDropdown = false;
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
                                controller: _costBaseController,
                                decoration: InputDecoration(
                                  prefixText: '\$',
                                  hintText: 'Costo base',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                validator: validateNumber,
                                onChanged: (value) {
                                  setState(() {}); // Update dialog state
                                },
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        if (selectedCostoBase == 'Costo base anual' || selectedCostoBase == 'Costo base actualizado al mes')
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                                ),
                                onPressed: () {
                                  _showEditReferenceDialog();
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
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  hint: const Text('Seleccione el mes'),
                                  value: selectedMes,
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
                                    setState(() {
                                      selectedMes = newValue;
                                    });
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
                          controller: _m2Controller,
                          decoration: InputDecoration(
                            suffixText: 'm²',
                            hintText: 'm² del proyecto',
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: validateNumber,
                          onChanged: (value) {
                            setState(() {}); // Update dialog state
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                    ),
                    onPressed: selectedSubcategoria != null &&
                        selectedCostoBase != null &&
                        (selectedCostoBase == 'Costo base calculado' &&
                            _costBaseController.text.isNotEmpty &&
                            _m2Controller.text.isNotEmpty) ||
                        (selectedCostoBase == 'Costo base anual' &&
                            _controllers.every((controller) => controller.text.isNotEmpty) &&
                            _inflationController.text.isNotEmpty &&
                            _m2Controller.text.isNotEmpty) ||
                        (selectedCostoBase == 'Costo base actualizado al mes' &&
                            _controllers.every((controller) => controller.text.isNotEmpty) &&
                            _inflationController.text.isNotEmpty &&
                            selectedMes != null &&
                            _m2Controller.text.isNotEmpty)
                        ? () {
                      double costoBase = 0.0;
                      double metrosCuadrados = double.parse(_m2Controller.text);
                      String? key = categoriasPrivadas
                        .firstWhere((categoria) => categoria.titulo == selectedCategoria!)
                        .subcategoriasKeys[categoriasPrivadas
                          .firstWhere((categoria) => categoria.titulo == selectedCategoria!)
                          .subcategorias
                          .indexOf(selectedSubcategoria!)];
                      double factor = factorDeCosto[key] ?? 1.0;
                      factor*=0.95;
                      double costoTotal = 0.0;

                      if (selectedCostoBase == 'Costo base calculado') {
                        costoBase = double.parse(_costBaseController.text);
                        costoTotal = costoBase * metrosCuadrados * factor;
                      } else {
                        double porcentajeInflacion = double.parse(_inflationController.text.replaceAll('%', '')) / 100;
                        porcentajeInflacion = double.parse((porcentajeInflacion).toStringAsFixed(4));
                        double sumaReferencias = 0;
                        int numReferenciasUsadas = 0;
                        for (int i = 0; i < _numReferences; i++) {
                          if (_controllers[i].text.isNotEmpty) {
                            sumaReferencias += double.parse(
                              _controllers[i].text.split(' - ')[1].replaceAll(RegExp(r'[^\d.]'), '')
                            );
                            numReferenciasUsadas++;
                          }
                        }
                        costoBase = sumaReferencias / numReferenciasUsadas;
                        costoBase += (costoBase * porcentajeInflacion);
                        if (selectedCostoBase == 'Costo base actualizado al mes') {
                          int valorMes = mesValor[selectedMes] ?? 1;
                          double inflacionMensual = (valorMes * 0.27) / 100;
                          costoBase += (costoBase * inflacionMensual);
                        }
                        costoTotal = costoBase * metrosCuadrados * factor;
                      }
                      costoTotal *= factorPorRegion[selectedRegion] ?? 1.0;
                      var formattedCostoTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costoTotal);

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Resumen del proyecto'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Categoría del proyecto: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '\n$selectedCategoria',
                                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                RichText(
                                  text: TextSpan(
                                    text: 'Tipo de edificación: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '\n$selectedSubcategoria',
                                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                RichText(
                                  text: TextSpan(
                                    text: 'Referencia de costo base: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '\n$selectedCostoBase',
                                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selectedCostoBase == 'Costo base actualizado al mes') ...[
                                  const SizedBox(height: 10.0),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Mes seleccionado: ',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '\n$selectedMes',
                                          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10.0),
                                RichText(
                                  text: TextSpan(
                                    text: 'Metros cuadrados del proyecto: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '\n${_m2Controller.text} m²',
                                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Costo directo de obra',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        formattedCostoTotal,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                                ),
                                child: const Text('Regresar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
                                ),
                                child: const Text('Siguiente'),
                                onPressed: () async {
                                  bool? fillDetails = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('¿Desea llenar los datos del formato de cotización?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Omitir'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Sí'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (fillDetails == true) {
                                    var formKey = GlobalKey<FormState>();
                                    TextEditingController caducidadController = TextEditingController();
                                    TextEditingController nombreEmpresaController = TextEditingController();
                                    TextEditingController telefonoController = TextEditingController();
                                    TextEditingController domicilioController = TextEditingController();
                                    TextEditingController correoController = TextEditingController();
                                    TextEditingController contratistaController = TextEditingController();
                                    TextEditingController telefonoContratistaController = TextEditingController();
                                    TextEditingController proyectoController = TextEditingController();
                                    TextEditingController giroProyectoController = TextEditingController();
                                    TextEditingController ubicacionProyectoController = TextEditingController();
                                    TextEditingController descripcionProyectoController = TextEditingController();

                                    bool? formSubmitted = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Datos del Presupuesto'),
                                          content: SingleChildScrollView(
                                            child: Form(
                                              key: formKey,
                                              child: Column(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () async {
                                                      DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2000),
                                                        lastDate: DateTime(2101),
                                                        locale: const Locale('es', 'ES'),
                                                      );
                                                      if (pickedDate != null) {
                                                        String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                                        setState(() {
                                                          caducidadController.text = formattedDate;
                                                        });
                                                      }
                                                    },
                                                    child: AbsorbPointer(
                                                      child: TextFormField(
                                                        controller: caducidadController,
                                                        decoration: const InputDecoration(
                                                          labelText: 'Fecha de caducidad',
                                                          hintText: 'Seleccione la fecha de caducidad',
                                                        ),
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Por favor ingrese la fecha de caducidad';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Nombre de la empresa o responsable',
                                                      hintText: 'Ingrese el nombre de la empresa o responsable',
                                                    ),
                                                    controller: nombreEmpresaController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el nombre de la empresa o responsable';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Teléfono',
                                                      hintText: 'Ingrese el número de teléfono',
                                                    ),
                                                    controller: telefonoController,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly,
                                                    ],
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el número de teléfono';
                                                      }
                                                      if (value.length != 10) {
                                                        return 'El número de teléfono debe tener 10 dígitos';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final domicilio = await mostrarDialogoDireccion(context, 'Ingresar Domicilio', valorInicial: domicilioController.text);
                                                      if (domicilio != null) {
                                                        setState(() {
                                                          domicilioController.text = domicilio;
                                                        });
                                                      }
                                                    },
                                                    child: AbsorbPointer(
                                                      child: TextFormField(
                                                        controller: domicilioController,
                                                        decoration: const InputDecoration(
                                                          labelText: 'Domicilio',
                                                          hintText: 'Ingrese el domicilio',
                                                        ),
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Por favor ingrese el domicilio';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Correo',
                                                      hintText: 'Ingrese el correo',
                                                    ),
                                                    controller: correoController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el correo';
                                                      }
                                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                                        return 'Por favor ingrese un correo válido';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Contratista',
                                                      hintText: 'Ingrese el nombre del contratista',
                                                    ),
                                                    controller: contratistaController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el nombre del contratista';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Teléfono del contratista',
                                                      hintText: 'Ingrese el número de teléfono del contratista',
                                                    ),
                                                    controller: telefonoContratistaController,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly,
                                                    ],
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el número de teléfono del contratista';
                                                      }
                                                      if (value.length != 10) {
                                                        return 'El número de teléfono del contratista debe tener 10 dígitos';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Proyecto',
                                                      hintText: 'Ingrese el nombre del proyecto',
                                                    ),
                                                    controller: proyectoController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el nombre del proyecto';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Giro del proyecto',
                                                      hintText: 'Ingrese el giro del proyecto',
                                                    ),
                                                    controller: giroProyectoController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el giro del proyecto';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final ubicacionProyecto = await mostrarDialogoDireccion(context, 'Ingresar Ubicación del Proyecto', valorInicial: ubicacionProyectoController.text);
                                                      if (ubicacionProyecto != null) {
                                                        setState(() {
                                                          ubicacionProyectoController.text = ubicacionProyecto;
                                                        });
                                                      }
                                                    },
                                                    child: AbsorbPointer(
                                                      child: TextFormField(
                                                        controller: ubicacionProyectoController,
                                                        decoration: const InputDecoration(
                                                          labelText: 'Ubicación del proyecto',
                                                          hintText: 'Ingrese la ubicación del proyecto',
                                                        ),
                                                        validator: (value) {
                                                          if (value == null || value.isEmpty) {
                                                            return 'Por favor ingrese la ubicación del proyecto';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Breve descripción del proyecto',
                                                      hintText: 'Ingrese una breve descripción del proyecto',
                                                    ),
                                                    controller: descripcionProyectoController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese una breve descripción del proyecto';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (formKey.currentState!.validate()) {
                                                  Navigator.of(context).pop(true);
                                                }
                                              },
                                              child: const Text('Guardar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (formSubmitted == true) {
                                      var detalle = PresupuestoDetalle(
                                        nombre: proyectoController.text,
                                        total: costoTotal,
                                        opcion: selectedSubcategoria ?? 'Sin Subcategoría',
                                        fechaEmision: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                        fechaCaducidad: caducidadController.text,
                                        nombreEmpresa: nombreEmpresaController.text,
                                        telefono: telefonoController.text,
                                        domicilio: domicilioController.text,
                                        correo: correoController.text,
                                        contratista: contratistaController.text,
                                        telefonoContratista: telefonoContratistaController.text,
                                        giroProyecto: giroProyectoController.text,
                                        ubicacionProyecto: ubicacionProyectoController.text,
                                        descripcionProyecto: descripcionProyectoController.text,
                                      );
                                      guardarPresupuestoPrivado(detalle);
                                      _handleSaveAndShare(context, detalle);
                                    }
                                  } else {
                                    TextEditingController proyectoController = TextEditingController();
                                    final formKey = GlobalKey<FormState>(); // Asegúrate de definir formKey aquí

                                    bool? nombreSubmitted = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Nombre del Proyecto'),
                                          content: SingleChildScrollView(
                                            child: Form(
                                              key: formKey,
                                              child: Column(
                                                children: <Widget>[
                                                  TextFormField(
                                                    decoration: const InputDecoration(
                                                      labelText: 'Nombre del Proyecto',
                                                      hintText: 'Ingrese el nombre del proyecto',
                                                    ),
                                                    controller: proyectoController,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese el nombre del proyecto';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (formKey.currentState!.validate()) {
                                                  Navigator.of(context).pop(true);
                                                }
                                              },
                                              child: const Text('Guardar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (nombreSubmitted == true) {
                                      var detalle = PresupuestoDetalle(
                                        nombre: proyectoController.text,
                                        total: costoTotal,
                                        opcion: selectedSubcategoria ?? 'Sin Subcategoría',
                                        fechaEmision: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                        fechaCaducidad: '',
                                        nombreEmpresa: '',
                                        telefono: '',
                                        domicilio: '',
                                        correo: '',
                                        contratista: '',
                                        telefonoContratista: '',
                                        giroProyecto: '',
                                        ubicacionProyecto: '',
                                        descripcionProyecto: '',
                                      );
                                      guardarPresupuestoPrivado(detalle);
                                      _handleSaveAndShare(context, detalle);
                                    }
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
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

  Future<bool> _checkAndRequestPermissions() async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      openAppSettings();
    }
    return status.isGranted;
  }

  void _shareFile(String filePath) {
    Share.shareXFiles([XFile(filePath)], text: 'Aquí tienes el archivo de presupuesto de obra privada.');
  }

  Future<void> _handleSaveAndShare(BuildContext context, PresupuestoDetalle presupuesto) async {
    if (await _checkAndRequestPermissions()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se seleccionó un directorio.')));
        return;
      }

      String? filePath = await _generateExcel(presupuesto, selectedDirectory);

      if (filePath != null) {
        _shareFile(filePath);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo Excel generado y listo para compartir')));
        MenuPage.menuPageKey.currentState?.openDrawerAndHighlightConstruccion();
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al generar el archivo.')));
      }
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso denegado. No se pudo guardar el archivo.')));
    }
  }

  Future<String?> _generateExcel(PresupuestoDetalle presupuesto, String selectedDirectory) async {
    final ByteData data = await rootBundle.load("assets/plantillas/PRESUPUESTO.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['Hoja1'];

    // Fecha de emisión y caducidad
    String fechaEmision = DateFormat('dd/MM/yyyy').format(DateTime.now());
    sheet.updateCell(CellIndex.indexByString('C2'), TextCellValue(fechaEmision));
    sheet.updateCell(CellIndex.indexByString('F2'), TextCellValue(presupuesto.fechaCaducidad));

    // Otros datos
    sheet.updateCell(CellIndex.indexByString('C4'), TextCellValue(presupuesto.nombreEmpresa));
    sheet.updateCell(CellIndex.indexByString('F4'), TextCellValue(presupuesto.telefono));
    sheet.updateCell(CellIndex.indexByString('C5'), TextCellValue(presupuesto.domicilio));
    sheet.updateCell(CellIndex.indexByString('C6'), TextCellValue(presupuesto.correo));
    sheet.updateCell(CellIndex.indexByString('C8'), TextCellValue(presupuesto.contratista));
    sheet.updateCell(CellIndex.indexByString('F8'), TextCellValue(presupuesto.telefonoContratista));
    sheet.updateCell(CellIndex.indexByString('C9'), TextCellValue(presupuesto.nombre));
    sheet.updateCell(CellIndex.indexByString('F9'), TextCellValue(presupuesto.giroProyecto));
    sheet.updateCell(CellIndex.indexByString('C10'), TextCellValue(presupuesto.ubicacionProyecto));
    sheet.updateCell(CellIndex.indexByString('C11'), TextCellValue(presupuesto.descripcionProyecto));
    // Merge y agregar valores
    sheet.merge(CellIndex.indexByString('A14'), CellIndex.indexByString('G14'), customValue: const TextCellValue('CONCEPTOS'));
    sheet.merge(CellIndex.indexByString('A15'), CellIndex.indexByString('F15'), customValue: const TextCellValue('OBRA'));
    sheet.merge(CellIndex.indexByString('A16'), CellIndex.indexByString('F16'), customValue: TextCellValue(presupuesto.opcion));
    var formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total);
    sheet.updateCell(CellIndex.indexByString('G16'), TextCellValue(formattedTotal));

    // Guardar el archivo
    String fileName = '${presupuesto.nombre}_ObraPrivada.xlsx';
    String filePath = '$selectedDirectory/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(excel.encode()!, flush: true);

    return filePath;
  }

  Future<String?> mostrarDialogoDireccion(BuildContext context, String titulo, {String? valorInicial}) async {
    TextEditingController calleController = TextEditingController();
    TextEditingController numeroController = TextEditingController();
    TextEditingController coloniaController = TextEditingController();
    TextEditingController cpController = TextEditingController();
    TextEditingController ciudadController = TextEditingController();
    TextEditingController estadoController = TextEditingController();

    if (valorInicial != null) {
      List<String> partes = valorInicial.split(', ');
      if (partes.length == 5) {
        calleController.text = partes[0].split(' #')[0];
        numeroController.text = partes[0].split(' #')[1];
        coloniaController.text = partes[1];
        cpController.text = partes[2];
        ciudadController.text = partes[3];
        estadoController.text = partes[4];
      }
    }

    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: calleController,
                    decoration: const InputDecoration(labelText: 'Calle'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la calle';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: numeroController,
                    decoration: const InputDecoration(labelText: 'Número'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el número';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: coloniaController,
                    decoration: const InputDecoration(labelText: 'Colonia'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la colonia';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: cpController,
                    decoration: const InputDecoration(labelText: 'CP'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el código postal';
                      }
                      if (value.length != 5) {
                        return 'El código postal debe tener 5 dígitos';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: ciudadController,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la ciudad';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: estadoController,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el estado';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String direccionCompleta =
                      '${calleController.text} #${numeroController.text}, ${coloniaController.text}, ${cpController.text}, ${ciudadController.text}, ${estadoController.text}';
                  Navigator.of(context).pop(direccionCompleta);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } 

  Future<void> guardarPresupuestoPrivado(PresupuestoDetalle presupuesto) async {
    var box = Hive.box<PresupuestoDetalle>('presupuestosPrivados');
    await box.put(presupuesto.nombre, presupuesto);
  }

  final Map<String, int> mesValor = {
    'Enero': 1,
    'Febrero': 2,
    'Marzo': 3,
    'Abril': 4,
    'Mayo': 5,
    'Junio': 6,
    'Julio': 7,
    'Agosto': 8,
    'Septiembre': 9,
    'Octubre': 10,
    'Noviembre': 11,
    'Diciembre': 12,
  };

  final Map<String, double> factorPorRegion = {
    '1': 0.92,
    '2': 0.96,
    '3': 1.00,
    '4': 0.97,
    '5': 1.00,
    '6': 0.98,
    '7': 0.92,
    '8': 0.95,
  };

}