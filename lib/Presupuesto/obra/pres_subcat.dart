// ignore_for_file: use_build_context_synchronously

import 'package:apparq/menu.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, FilteringTextInputFormatter, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'dart:convert';
import 'package:excel/excel.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

bool _isLoading = true;
class PresSubcatPage extends StatefulWidget {
  final String categoriaSeleccionada;
  final String subcategoriaSeleccionada;
  final String opcion;

  const PresSubcatPage({
    super.key,
    required this.categoriaSeleccionada,
    required this.subcategoriaSeleccionada,
    required this.opcion, 
  });

  @override
  // ignore: library_private_types_in_public_api
  _PresSubcatPageState createState() => _PresSubcatPageState();
}

class _PresSubcatPageState extends State<PresSubcatPage> {
  List<Categoria> categoriasList = [];
  String? subcategoriaSeleccionada;
  String selectedRegion = '';

  @override
  void initState() {
    super.initState();
    loadCSV();
  }


  Future<void> loadCSV() async {
    setState(() {
      _isLoading = true;  // Comienza la carga
    });
    final prefs = await SharedPreferences.getInstance();
    String? region = prefs.getString('selected_region');
    if (region != null) {
      setState(() {
        selectedRegion = region;
      });
    }
    
    final subcategoriaMayusculas = removeAccents(widget.subcategoriaSeleccionada.toUpperCase());
    final opcionMayusculas = removeAccents(widget.opcion.toUpperCase());
    String ruta = '${widget.categoriaSeleccionada}/$subcategoriaMayusculas/$opcionMayusculas/archivo.csv';
    String rutaRegion = 'REGION/$selectedRegion/$selectedRegion.csv';
    //print(selectedRegion);

    try {
      final ByteData data = await rootBundle.load('assets/csv/$ruta');
      final List<int> bytes = data.buffer.asUint8List();
      final String csvString = utf8.decode(bytes);
      List<List<dynamic>> parsedCSV = const CsvToListConverter().convert(csvString);
      List<Categoria> tempCategoriasList = [];
      Categoria? categoriaActual;
      Subcat? subcategoriaActual;

      final ByteData dataRegion = await rootBundle.load('assets/csv/$rutaRegion');
      final List<int> bytesRegion = dataRegion.buffer.asUint8List();
      final String csvStringRegion = utf8.decode(bytesRegion);
      List<List<dynamic>> parsedCSVRegion = const CsvToListConverter().convert(csvStringRegion);

      for (var row in parsedCSV) {
        if (row.isNotEmpty && row[0] is String) {
          final codigo = row[0];

          if (codigo.length == 3) {
            categoriaActual = Categoria(nombre: row[1], subcategorias: []);
            tempCategoriasList.add(categoriaActual);
          } else if (codigo.length == 5 && categoriaActual != null) {
            subcategoriaActual = Subcat(nombre: row[1], productos: []);
            categoriaActual.subcategorias.add(subcategoriaActual);
          } else if (codigo.length > 0 && subcategoriaActual != null && row[1].length > 0) {
            final nombre = row.isNotEmpty ? row[1] : '';
            final unidad = row.isNotEmpty ? row[2] : '';
            final matchingRow = parsedCSVRegion.firstWhere((row) => row.isNotEmpty && row[0] == codigo, orElse: () => []);
            final precioString = matchingRow.isNotEmpty ? matchingRow[4].toString().replaceAll('\$', '').replaceAll(',', '') : '0';
            //print('codigo: $codigo');
            final precio = double.tryParse(precioString) ?? 0;
            
            final cantidadString = row.isNotEmpty ? row[3].toString().replaceAll(',', '') : '0';
            //print('CantidadString: $cantidadString');
            final cantidad = double.tryParse(cantidadString) ?? 0;
            //print('Cantidad: $cantidad');
            subcategoriaActual.productos.add(Producto(
              clave: codigo,
              nombre: nombre,
              unidad: unidad,
              precio: precio,
              cantidad: cantidad,
            ));
          }
        }
      }

      setState(() {
        categoriasList = tempCategoriasList;
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar el archivo CSV: $e');
      setState(() {
        _isLoading = false;  // Termina la carga incluso si hay un error
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: 24,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 20), // Espacio entre el indicador y el texto
                const Text('Cargando datos, por favor espera...', style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        : Column(
        children: [
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: categoriasList.length,
                itemBuilder: (context, index) {
                  final categoria = categoriasList[index];
                  return ExpansionTile(
                    iconColor: const Color(0xFF044C70),
                    collapsedIconColor: const Color(0xFF044C70),
                    backgroundColor:  const Color.fromARGB(255, 179, 180, 181),
                    collapsedBackgroundColor: const Color.fromARGB(255, 179, 180, 181),
                    title: Text(categoria.nombre),
                    children: [
                      ...categoria.subcategorias.map(
                        (subcategoria) => ExpansionTile(
                          iconColor: const Color(0xFF044C70),
                          collapsedIconColor: const Color(0xFF044C70),
                          backgroundColor: const Color(0xEEEEEEEE),
                          collapsedBackgroundColor: const Color(0xEEEEEEEE),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(subcategoria.nombre),
                          ),
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FlexColumnWidth(2.6), // Columna del nombre
                                  1: FlexColumnWidth(1.2), // Columna de la cantidad
                                  2: FlexColumnWidth(1.0), // Columna de la unidad
                                  3: FlexColumnWidth(1.2), // Columna del precio
                                },
                                children: [
                                  // Fila de títulos
                                  const TableRow(
                                    children: [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Filas de datos para cada producto
                                  ...subcategoria.productos.map((producto) => TableRow(
                                    children: [
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(producto.nombre),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: TextFormField(
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                            ],
                                            textAlign: TextAlign.center,
                                            controller: producto.controller,
                                            onTap: () {
                                              producto.controller.selection = TextSelection(
                                                baseOffset: 0,
                                                extentOffset: producto.controller.text.length,
                                              );
                                            },
                                            onChanged: (String valor) {
                                              if (valor == ".") {
                                                valor = "0.";
                                              }
                                              setState(() {
                                                producto.cantidad = double.tryParse(valor) ?? 0;
                                                producto.controller.text = valor;
                                                producto.controller.selection = TextSelection.fromPosition(TextPosition(offset: producto.controller.text.length));
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(child: Text(producto.unidad, textAlign: TextAlign.center)),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(child: Text('\$${producto.precio}', textAlign: TextAlign.center)),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              )
                            )
                          ],
                        )
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Resumen del Presupuesto'),
                      content: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: buildResumenPresupuesto(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                        TextButton(
                          onPressed: () async {
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

                            // Solicita los datos mediante un diálogo
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
                                total: categoriasList.fold(0, (total, cat) => total + cat.subcategorias.fold(0, (subTotal, sub) => subTotal + sub.productos.fold(0, (prodTotal, prod) => prodTotal + prod.precio * prod.cantidad))),
                                opcion: widget.opcion,
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
                              guardarPresupuesto(detalle);
                              _handleSaveAndShare(context, detalle);
                            }
                          },
                          child: const Text('Descargar Excel'),
                        )
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF044C70),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              ),
              child: const Text(
                'Calcular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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




  Column buildResumenPresupuesto() {
    double totalGeneral = 0.0;
    List<Widget> children = [];
    List<Categoria?> categoriasConProductos = obtenerCategoriasConProductos();

    for (var categoria in categoriasConProductos) {
      double totalCategoria = 0.0;
      for (var subcategoria in categoria!.subcategorias) {
        for (var producto in subcategoria.productos) {
          double precioTotalProducto = producto.cantidad * producto.precio;
          totalCategoria += precioTotalProducto;
        }
      }
      final formattedCategoria = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalCategoria);
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${categoria.nombre}: ', style: const TextStyle(fontWeight: FontWeight.bold), ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Text(formattedCategoria, style: const TextStyle(color: Colors.black), textAlign: TextAlign.right, ),
              ),
            ],
          ),
        ),
      );
      totalGeneral += totalCategoria;
    }

    final formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalGeneral);
    children.add(
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total General: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black), ),
            Text(formattedTotal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }


  List<Categoria?> obtenerCategoriasConProductos() {
    return categoriasList.map((categoria) {
      // Filtrar subcategorias con productos con cantidad > 0
      List<Subcat> subcategoriasFiltradas = categoria.subcategorias
          .where((subcat) => subcat.productos.any((producto) => producto.cantidad > 0))
          .toList();

      // Crear nuevas subcategori­as con productos filtrados
      subcategoriasFiltradas = subcategoriasFiltradas.map((subcat) {
        List<Producto> productosFiltrados =
            subcat.productos.where((producto) => producto.cantidad > 0).toList();
        return Subcat(nombre: subcat.nombre, productos: productosFiltrados);
      }).toList();

      if(subcategoriasFiltradas.isNotEmpty) {
        return Categoria(nombre: categoria.nombre, subcategorias: subcategoriasFiltradas);
      }
      return null;
    }).whereType<Categoria>().toList();
  }

  Future<bool> _checkAndRequestPermissions() async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      openAppSettings();
    }
    return status.isGranted;
  }
  Future<String?> _generateExcel(PresupuestoDetalle presupuesto, String selectedDirectory) async {
    final ByteData data = await rootBundle.load("assets/plantillas/PRESUPUESTO.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['Hoja1'];

    var j = 0;
    double suma = 0;
    for (var categoria in categoriasList) {
      for (var subcategoria in categoria.subcategorias) {
        for (var producto in subcategoria.productos) {
          suma += producto.precio * producto.cantidad;
          sheet.updateCell(CellIndex.indexByString('A${16 + j}'), TextCellValue(producto.clave));
          sheet.merge(CellIndex.indexByString('B${16 + j}'), CellIndex.indexByString('C${16 + j}'), customValue: TextCellValue(producto.nombre));
          sheet.updateCell(CellIndex.indexByString('D${16 + j}'), DoubleCellValue(producto.cantidad));
          sheet.updateCell(CellIndex.indexByString('E${16 + j}'), TextCellValue(producto.unidad));
          sheet.updateCell(CellIndex.indexByString('F${16 + j}'), DoubleCellValue(producto.precio));
          sheet.updateCell(CellIndex.indexByString('G${16 + j}'), DoubleCellValue(producto.precio * producto.cantidad));
          j += 1;
        }
      }
    }
    sheet.updateCell(CellIndex.indexByString('G${16 + j}'), DoubleCellValue(suma));

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

    // Guardar el archivo
    String fileName = '${presupuesto.nombre}.xlsx';
    String filePath = '$selectedDirectory/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(excel.encode()!, flush: true);

    return filePath;
  }
  void _shareFile(String filePath) {
    Share.shareXFiles([XFile(filePath)], text: 'Aquí tienes el archivo de presupuesto.');
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
}



Future<void> guardarPresupuesto(PresupuestoDetalle presupuesto) async {
  var box = Hive.box<PresupuestoDetalle>('presupuestos');
  await box.put(presupuesto.nombre, presupuesto);
}

String removeAccents(String input) {
  return input
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U');
}

class Categoria {
  final String nombre;
  final List<Subcat> subcategorias;

  Categoria({
    required this.nombre,
    required this.subcategorias,
  });
}

class Subcat {
  final String nombre;
  final List<Producto> productos;

  Subcat({
    required this.nombre,
    required this.productos,
  });
}

class Producto {
  final String clave;
  final String nombre;
  final String unidad;
  double cantidad;
  final double precio;
  TextEditingController controller;

  Producto({
    required this.clave,
    required this.nombre,
    required this.unidad,
    required this.precio,
    required this.cantidad,
  }) : controller = TextEditingController(text: cantidad.toStringAsFixed(2));
}