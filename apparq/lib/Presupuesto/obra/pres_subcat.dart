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
                                          TextFormField(decoration: const InputDecoration(hintText: 'Fecha de caducidad'), controller: caducidadController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Nombre de la empresa o responsable'), controller: nombreEmpresaController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Teléfono'), controller: telefonoController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Domicilio'), controller: domicilioController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Correo'), controller: correoController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Contratista'), controller: contratistaController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Teléfono del contratista'), controller: telefonoContratistaController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Proyecto'), controller: proyectoController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Giro del proyecto'), controller: giroProyectoController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Ubicación del proyecto'), controller: ubicacionProyectoController),
                                          TextFormField(decoration: const InputDecoration(hintText: 'Breve descripción del proyecto'), controller: descripcionProyectoController),
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
                              var status = await Permission.manageExternalStorage.request();
                              status = await Permission.manageExternalStorage.status;
                              if (!status.isGranted) {
                                openAppSettings();
                              }

                              status = await Permission.manageExternalStorage.status;
                              if (status.isGranted) {
                                String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                final ByteData data = await rootBundle.load("assets/plantillas/PRESUPUESTO.xlsx");
                                var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
                                var excel = Excel.decodeBytes(bytes);
                                var sheet = excel['Hoja1'];

                                var j = 0;
                                double suma = 0;
                                for (var categoria in categoriasList) {
                                  for (var subcategoria in categoria.subcategorias) {
                                    for (var producto in subcategoria.productos) {
                                      suma = suma + (producto.precio*producto.cantidad);
                                      sheet.updateCell(CellIndex.indexByString('A${16 + j}'), TextCellValue(producto.clave));
                                      sheet.merge(CellIndex.indexByString('B${16 + j}'), CellIndex.indexByString('C${16 + j}'), customValue: TextCellValue(producto.nombre));
                                      sheet.updateCell(CellIndex.indexByString('D${16 + j}'), DoubleCellValue(producto.cantidad));
                                      sheet.updateCell(CellIndex.indexByString('E${16 + j}'), TextCellValue(producto.unidad));
                                      sheet.updateCell(CellIndex.indexByString('F${16 + j}'), DoubleCellValue(producto.precio));
                                      sheet.updateCell(CellIndex.indexByString('G${16 + j}'), DoubleCellValue(producto.precio*producto.cantidad));
                                      j += 1;
                                    }
                                  }
                                }
                                sheet.updateCell(CellIndex.indexByString('G${16 + j}'), DoubleCellValue(suma));

                                // Fecha de emisión y caducidad
                                String fechaEmision = DateFormat('dd/MM/yyyy').format(DateTime.now());
                                sheet.updateCell(CellIndex.indexByString('C2'), TextCellValue(fechaEmision));
                                sheet.updateCell(CellIndex.indexByString('F2'), TextCellValue(caducidadController.text));

                                // Otros datos
                                sheet.updateCell(CellIndex.indexByString('C4'), TextCellValue(nombreEmpresaController.text));
                                sheet.updateCell(CellIndex.indexByString('F4'), TextCellValue(telefonoController.text));
                                sheet.updateCell(CellIndex.indexByString('C5'), TextCellValue(domicilioController.text));
                                sheet.updateCell(CellIndex.indexByString('C6'), TextCellValue(correoController.text));
                                sheet.updateCell(CellIndex.indexByString('C8'), TextCellValue(contratistaController.text));
                                sheet.updateCell(CellIndex.indexByString('F8'), TextCellValue(telefonoContratistaController.text));
                                sheet.updateCell(CellIndex.indexByString('C9'), TextCellValue(proyectoController.text));
                                sheet.updateCell(CellIndex.indexByString('F9'), TextCellValue(giroProyectoController.text));
                                sheet.updateCell(CellIndex.indexByString('C10'), TextCellValue(ubicacionProyectoController.text));
                                sheet.updateCell(CellIndex.indexByString('C11'), TextCellValue(descripcionProyectoController.text));

                                // Guardar el archivo
                                String fileName = '${proyectoController.text}.xlsx';
                                String filePath = '$selectedDirectory/$fileName';
                                File file = File(filePath);
                                await file.writeAsBytes(excel.encode()!, flush: true);

                                // Guarda el nombre y el total en Hive
                                double totalPresupuesto = categoriasList.fold(0, (total, cat) => total + cat.subcategorias.fold(0, (subTotal, sub) => subTotal + sub.productos.fold(0, (prodTotal, prod) => prodTotal + prod.precio * prod.cantidad)));
                                var detalle = PresupuestoDetalle(nombre: proyectoController.text, 
                                                                 total: totalPresupuesto, 
                                                                 opcion: widget.opcion, 
                                                                 fechaEmision: fechaEmision, 
                                                                 fechaCaducidad: caducidadController.text, 
                                                                 nombreEmpresa: nombreEmpresaController.text, 
                                                                 telefono: telefonoController.text, 
                                                                 domicilio: domicilioController.text,
                                                                 correo: correoController.text, 
                                                                 contratista: contratistaController.text, 
                                                                 telefonoContratista: telefonoContratistaController.text, 
                                                                 giroProyecto: giroProyectoController.text, 
                                                                 ubicacionProyecto: ubicacionProyectoController.text, 
                                                                 descripcionProyecto: descripcionProyectoController.text);
                                guardarPresupuesto(detalle);
                                print('Total Presupuesto: $totalPresupuesto');
                                
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Archivo Excel generado en $filePath')),
                                );
                                
                              } else {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Permiso denegado. No se pudo guardar el archivo.')),
                                );
                              }
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