// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:share_plus/share_plus.dart';


class ConstruccionPage extends StatefulWidget {
  const ConstruccionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConstruccionPage createState() => _ConstruccionPage();
}

class _ConstruccionPage extends State<ConstruccionPage> {
  List<PresupuestoDetalle> presupuestos = [];
  List<String> descripciones = [
    'Indirectos de oficina',
    'Indirectos de campo',
    'Financiamiento',
    'Utilidad',
    'Cargos adicionales',
    'Otro porcentaje',
  ];
  final List<TextEditingController> percentageControllers = List.generate(6, (index) => TextEditingController(text: '0'));
  final ValueNotifier<double> totalPorcentajeNotifier = ValueNotifier<double>(0.0);
  @override
  void initState() {
    super.initState();
    // Obtener la lista de presupuestos al iniciar el widget
    presupuestos = obtenerPresupuestos();
    for (var controller in percentageControllers) {
      controller.addListener(_updateTotalPorcentaje);
    }
  }
  
  @override
  void dispose() {
    for (var controller in percentageControllers) {
      controller.removeListener(_updateTotalPorcentaje);
      controller.dispose();
    }
    totalPorcentajeNotifier.dispose();
    super.dispose();
  }

  void _updateTotalPorcentaje() {
    double total = 0.0;
    for (var controller in percentageControllers) {
      total += double.tryParse(controller.text) ?? 0.0;
    }
    totalPorcentajeNotifier.value = total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: presupuestos.length,
          itemBuilder: (context, index) {
            final presupuesto = presupuestos[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: ListTile(
                title: Text(presupuesto.nombre),
                onTap: () {
                  mostrarPopupPresupuesto(presupuesto);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _mostrarDialogoDeConfirmacion(presupuesto.nombre),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoDeConfirmacion(String nombre) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar la construcción y los presupuestos asociados para "$nombre"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      _borrarConstruccion(nombre);
    }
  }

  void _borrarConstruccion(String nombre) {
    var boxConstrucciones = Hive.box<ConstruccionDetalle>('construcciones');
    var boxPresupuestos = Hive.box<PresupuestoDetalle>('presupuestos');
    boxConstrucciones.delete(nombre);
    boxPresupuestos.delete(nombre); // Asume que los nombres son las claves en ambas cajas

    setState(() {
      presupuestos = obtenerPresupuestos(); // Actualizar la lista tras borrar los datos
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Construcción y presupuestos asociados eliminados')),
    );
  }

  void mostrarPopupPresupuesto(PresupuestoDetalle presupuesto) {
    final formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total);
    var detalle = obtenerDetalleConstruccion(presupuesto.nombre);
    if (detalle != null) {
      for (int i = 0; i < percentageControllers.length; i++) {
        percentageControllers[i].text = detalle.porcentajes[i].toStringAsFixed(2);
      }
    } else {
      for (var controller in percentageControllers) {
        controller.text = '0.00';
      }
    }

    List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (!focusNodes[i].hasFocus) {
          setState(() {
            percentageControllers[i].text = (double.tryParse(percentageControllers[i].text) ?? 0.00).toStringAsFixed(2);
            _updateTotalPorcentaje();
          });
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Indirectos de ${presupuesto.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: $formattedTotal'),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.7),
                        },
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('DESCRIPCION'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('PORCENTAJE'),
                              ),
                            ],
                          ),
                          ...List.generate(6, (index) => TableRow(
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(descripciones[index]),
                                  ),
                                ),
                              ),
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: percentageControllers[index],
                                    focusNode: focusNodes[index],
                                    decoration: const InputDecoration(
                                      hintText: '%',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                    ],
                                    onTap: () {
                                      percentageControllers[index].selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset: percentageControllers[index].text.length,
                                      );
                                    },
                                    onEditingComplete: () {
                                      setState(() {
                                        percentageControllers[index].text = (double.tryParse(percentageControllers[index].text) ?? 0.00).toStringAsFixed(2);
                                        _updateTotalPorcentaje();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder<double>(
                valueListenable: totalPorcentajeNotifier,
                builder: (context, total, child) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Total de porcentajes: ${total.toStringAsFixed(2)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el popup
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                mostrarDialogoDeConfirmacion(presupuesto);
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }


  Future<void> mostrarDialogoDeConfirmacion(PresupuestoDetalle presupuesto) async {
    List<double> porcentajes = [];
    double sumTotal = 0.0;
    
    for (int i = 0; i < percentageControllers.length; i++) {
      var percentageValue = double.tryParse(percentageControllers[i].text) ?? 0;
      porcentajes.add(percentageValue);
      var costo = presupuesto.total * percentageValue / 100;
      sumTotal += costo;
    }
    // Mostrar diálogo de confirmación con los valores calculados
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de Cambios'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total original: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
                ...List.generate(porcentajes.length, (index) {
                  double costo = presupuesto.total * porcentajes[index] / 100;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${descripciones[index]}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Descripción en negritas
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '(${porcentajes[index]}%) ',
                              style: const TextStyle(color: Colors.black), // Porcentaje normal
                            ),
                            TextSpan(
                              text: NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costo),
                              style: const TextStyle(color: Colors.black), // Valor normal
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nuevo total: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total + sumTotal),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                guardarExcel(presupuesto);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar y Guardar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> guardarExcel(PresupuestoDetalle presupuesto) async {
    var status = await Permission.manageExternalStorage.request();
    status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      openAppSettings();
    }

    status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // El usuario canceló la selección de directorio
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se seleccionó un directorio.'),
          ),
        );
        return;
      }

      final ByteData data = await rootBundle.load("assets/plantillas/CONSTRUCCION.xlsx");
      var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      var excel = Excel.decodeBytes(bytes);
      var sheet = excel['Hoja1']; 

      sheet.updateCell(CellIndex.indexByString('C2'), TextCellValue(presupuesto.fechaEmision));
      sheet.updateCell(CellIndex.indexByString('F2'), TextCellValue(presupuesto.fechaCaducidad));
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

      var formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total);
      sheet.updateCell(CellIndex.indexByString('E13'), TextCellValue(formattedTotal));
      var sumTotal = 0.0;
      List<double> porcentajes = [];
      for (int i = 0; i < percentageControllers.length; i++) {
        var percentageValue = double.tryParse(percentageControllers[i].text) ?? 0;
        porcentajes.add(percentageValue);
        var costo = presupuesto.total * percentageValue / 100;
        sheet.updateCell(CellIndex.indexByString('D${17 + i}'), TextCellValue('$percentageValue%'));
        var formattedCosto = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costo);
        sheet.updateCell(CellIndex.indexByString('E${17 + i}'), TextCellValue(formattedCosto));
        sumTotal += costo;
      }

      var formattedSumTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(sumTotal);
      sheet.updateCell(CellIndex.indexByString('E23'), TextCellValue(formattedSumTotal));
      var formattedFinal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total + sumTotal);
      sheet.updateCell(CellIndex.indexByString('E26'), TextCellValue(formattedFinal));

      String fileName = '${presupuesto.nombre}_Construccion.xlsx';
      String filePath = '$selectedDirectory/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(excel.encode()!, flush: true);

      // Guarda en Hive
      var detalle = ConstruccionDetalle(nombreArchivo: fileName, porcentajes: porcentajes);
      guardarDetalleConstruccion(presupuesto.nombre, detalle);
      
      _shareFile(filePath);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo Excel generado y listo para compartir')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso denegado. No se pudo guardar el archivo.'),
        ),
      );
    }
  }
}

void _shareFile(String filePath) {
  Share.shareXFiles([XFile(filePath)], text: 'Aquí tienes el archivo de presupuesto.');
}

Future<void> guardarDetalleConstruccion(String nombre, ConstruccionDetalle detalle) async {
  var box = Hive.box<ConstruccionDetalle>('construcciones');
  await box.put(nombre, detalle);
}

List<PresupuestoDetalle> obtenerPresupuestos() {
  var box = Hive.box<PresupuestoDetalle>('presupuestos');
  return box.values.toList();
}

ConstruccionDetalle? obtenerDetalleConstruccion(String nombrePresupuesto) {
  var box = Hive.box<ConstruccionDetalle>('construcciones');
  return box.get(nombrePresupuesto);
}