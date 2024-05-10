import 'dart:io';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:apparq/models/construccion_detalle.dart';


class ConstruccionPage extends StatefulWidget {
  const ConstruccionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConstruccionPage createState() => _ConstruccionPage();
}

class _ConstruccionPage extends State<ConstruccionPage> {
  List<PresupuestoDetalle> presupuestos = [];
  final List<TextEditingController> percentageControllers = List.generate(6, (index) => TextEditingController(text: '0'));
  @override
  void initState() {
    super.initState();
    // Obtener la lista de presupuestos al iniciar el widget
    presupuestos = obtenerPresupuestos(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: presupuestos.length,
          itemBuilder: (context, index) {
            final presupuesto = presupuestos[index];
            return ListTile(
              title: Text(presupuesto.nombre),
              onTap: () {
                mostrarPopupPresupuesto(presupuesto);
              },
            );
          },
        ),
      ),
    );
  }

  void mostrarPopupPresupuesto(PresupuestoDetalle presupuesto) {
    final formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total);
    List<String> descripciones = [
      'Indirectos de oficina',
      'Indirectos de campo',
      'Financiamiento',
      'Utilidad',
      'Cargos adicionales',
      'Otro porcentaje',
    ];
    var detalle = obtenerDetalleConstruccion(presupuesto.nombre);
    if (detalle != null) {
      for (int i = 0; i < percentageControllers.length; i++) {
        percentageControllers[i].text = detalle.porcentajes[i].toStringAsFixed(2);  // Formatea a dos decimales si es necesario
      }
    } else {
      for (var controller in percentageControllers) {
        controller.text = '0';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalle de ${presupuesto.nombre}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Total: $formattedTotal'),
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
                              decoration: const InputDecoration(
                                hintText: '%',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              onTap: () {
                                // Selecciona todo el texto al enfocar el campo
                                percentageControllers[index].selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: percentageControllers[index].text.length,
                                );
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el popup
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                guardarExcel(presupuesto);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar Cambios'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo Excel generado en $filePath')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso denegado. No se pudo guardar el archivo.'),
        ),
      );
    }
  }
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