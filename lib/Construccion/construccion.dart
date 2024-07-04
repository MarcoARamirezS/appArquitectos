// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:apparq/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:share_plus/share_plus.dart';

class ConstruccionPage extends StatefulWidget {
  const ConstruccionPage({super.key});

  @override
  _ConstruccionPage createState() => _ConstruccionPage();
}

class _ConstruccionPage extends State<ConstruccionPage> {
  List<PresupuestoDetalle> presupuestosPublicos = [];
  List<PresupuestoDetalle> presupuestosPrivados = [];
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
    presupuestosPublicos = obtenerPresupuestos('presupuestos');
    presupuestosPrivados = obtenerPresupuestos('presupuestosPrivados');
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
        child: ListView(
          children: [
            ExpansionTile(
              title: const Text('Presupuestos Públicos'),
              children: presupuestosPublicos.map((presupuesto) {
                return ListTile(
                  title: Text(presupuesto.nombre),
                  onTap: () {
                    mostrarPopupPresupuesto(presupuesto, false);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _mostrarDialogoDeConfirmacion(presupuesto.nombre, false),
                  ),
                );
              }).toList(),
            ),
            ExpansionTile(
              title: const Text('Presupuestos Privados'),
              children: presupuestosPrivados.map((presupuesto) {
                return ListTile(
                  title: Text(presupuesto.nombre),
                  onTap: () {
                    mostrarPopupPresupuesto(presupuesto, true);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _mostrarDialogoDeConfirmacion(presupuesto.nombre, true),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoDeConfirmacion(String nombre, bool esPrivado) async {
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
      _borrarConstruccion(nombre, esPrivado);
    }
  }

  void _borrarConstruccion(String nombre, bool esPrivado) {
    var boxConstrucciones = Hive.box<ConstruccionDetalle>(esPrivado ? 'construccionesPrivadas' : 'construcciones');
    var boxPresupuestos = Hive.box<PresupuestoDetalle>(esPrivado ? 'presupuestosPrivados' : 'presupuestos');
    boxConstrucciones.delete(nombre);
    boxPresupuestos.delete(nombre);

    setState(() {
      if (esPrivado) {
        presupuestosPrivados = obtenerPresupuestos('presupuestosPrivados');
      } else {
        presupuestosPublicos = obtenerPresupuestos('presupuestos');
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Construcción y presupuestos asociados eliminados')),
    );
  }

  void mostrarPopupPresupuesto(PresupuestoDetalle presupuesto, bool esPrivado) {
    final formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total);
    var detalle = obtenerDetalleConstruccion(presupuesto.nombre, esPrivado);
    if (detalle != null) {
      for (int i = 0; i < percentageControllers.length; i++) {
        percentageControllers[i].text = detalle.porcentajes[i].toStringAsFixed(2);
      }
    } else {
      // Valores por defecto
      List<double> valoresPorDefecto = [8, 5, 3, 7, 0, 0];
      for (int i = 0; i < percentageControllers.length; i++) {
        percentageControllers[i].text = valoresPorDefecto[i].toStringAsFixed(2);
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
                mostrarDialogoDeConfirmacion(presupuesto, esPrivado);
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  Future<void> mostrarDialogoDeConfirmacion(PresupuestoDetalle presupuesto, bool esPrivado) async {
    List<double> porcentajes = [];
    
    double indirectosDeOficina = (presupuesto.total * (double.tryParse(percentageControllers[0].text) ?? 0) / 100);
    indirectosDeOficina = double.parse(indirectosDeOficina.toStringAsFixed(2));
    double indirectosDeCampo = (presupuesto.total * (double.tryParse(percentageControllers[1].text) ?? 0) / 100);
    indirectosDeCampo = double.parse(indirectosDeCampo.toStringAsFixed(2));
    double subtotal1 = indirectosDeOficina + indirectosDeCampo + presupuesto.total;

    double financiamiento = (subtotal1 * (double.tryParse(percentageControllers[2].text) ?? 0) / 100);
    financiamiento = double.parse(financiamiento.toStringAsFixed(2));
    double subtotal2 = subtotal1 + financiamiento;

    double utilidad = subtotal2 * (double.tryParse(percentageControllers[3].text) ?? 0) / 100;
    utilidad = double.parse(utilidad.toStringAsFixed(2));
    double subtotal3 = subtotal2 + utilidad;

    double cargosAdicionales = subtotal3 * (double.tryParse(percentageControllers[4].text) ?? 0) / 100;
    cargosAdicionales = double.parse(cargosAdicionales.toStringAsFixed(2));
    double subtotal4 = subtotal3 + cargosAdicionales;

    double otrosPorcentajes = subtotal4 * (double.tryParse(percentageControllers[5].text) ?? 0) / 100;
    otrosPorcentajes = double.parse(otrosPorcentajes.toStringAsFixed(2));
    double totalIndirectos = indirectosDeOficina + indirectosDeCampo + financiamiento + utilidad + cargosAdicionales + otrosPorcentajes;
    totalIndirectos = double.parse(totalIndirectos.toStringAsFixed(2));

    porcentajes = [
      double.tryParse(percentageControllers[0].text) ?? 0,
      double.tryParse(percentageControllers[1].text) ?? 0,
      double.tryParse(percentageControllers[2].text) ?? 0,
      double.tryParse(percentageControllers[3].text) ?? 0,
      double.tryParse(percentageControllers[4].text) ?? 0,
      double.tryParse(percentageControllers[5].text) ?? 0,
    ];

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
                  double costo = 0;
                  String descripcion = descripciones[index];
                  if (index == 0) costo = indirectosDeOficina;
                  if (index == 1) costo = indirectosDeCampo;
                  if (index == 2) costo = financiamiento;
                  if (index == 3) costo = utilidad;
                  if (index == 4) costo = cargosAdicionales;
                  if (index == 5) costo = otrosPorcentajes;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$descripcion: ',
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
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total de indirectos: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalIndirectos),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nuevo total: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total + totalIndirectos),
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
                guardarExcel(presupuesto, esPrivado);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar y Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> guardarExcel(PresupuestoDetalle presupuesto, bool esPrivado) async {
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

      double indirectosDeOficina = (presupuesto.total * (double.tryParse(percentageControllers[0].text) ?? 0) / 100);
      indirectosDeOficina = double.parse(indirectosDeOficina.toStringAsFixed(2));
      double indirectosDeCampo = (presupuesto.total * (double.tryParse(percentageControllers[1].text) ?? 0) / 100);
      indirectosDeCampo = double.parse(indirectosDeCampo.toStringAsFixed(2));
      double subtotal1 = indirectosDeOficina + indirectosDeCampo + presupuesto.total;

      double financiamiento = (subtotal1 * (double.tryParse(percentageControllers[2].text) ?? 0) / 100);
      financiamiento = double.parse(financiamiento.toStringAsFixed(2));
      double subtotal2 = subtotal1 + financiamiento;

      double utilidad = subtotal2 * (double.tryParse(percentageControllers[3].text) ?? 0) / 100;
      utilidad = double.parse(utilidad.toStringAsFixed(2));
      double subtotal3 = subtotal2 + utilidad;

      double cargosAdicionales = subtotal3 * (double.tryParse(percentageControllers[4].text) ?? 0) / 100;
      cargosAdicionales = double.parse(cargosAdicionales.toStringAsFixed(2));
      double subtotal4 = subtotal3 + cargosAdicionales;

      double otrosPorcentajes = subtotal4 * (double.tryParse(percentageControllers[5].text) ?? 0) / 100;
      otrosPorcentajes = double.parse(otrosPorcentajes.toStringAsFixed(2));
      double totalIndirectos = indirectosDeOficina + indirectosDeCampo + financiamiento + utilidad + cargosAdicionales + otrosPorcentajes;
      totalIndirectos = double.parse(totalIndirectos.toStringAsFixed(2));

      var formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(presupuesto.total);
      sheet.updateCell(CellIndex.indexByString('E13'), TextCellValue(formattedTotal));

      List<double> porcentajes = [
        double.tryParse(percentageControllers[0].text) ?? 0,
        double.tryParse(percentageControllers[1].text) ?? 0,
        double.tryParse(percentageControllers[2].text) ?? 0,
        double.tryParse(percentageControllers[3].text) ?? 0,
        double.tryParse(percentageControllers[4].text) ?? 0,
        double.tryParse(percentageControllers[5].text) ?? 0,
      ];

      var formattedIndirectosDeOficina = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(indirectosDeOficina);
      sheet.updateCell(CellIndex.indexByString('D17'), TextCellValue('${porcentajes[0]}%'));
      sheet.updateCell(CellIndex.indexByString('E17'), TextCellValue(formattedIndirectosDeOficina));

      var formattedIndirectosDeCampo = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(indirectosDeCampo);
      sheet.updateCell(CellIndex.indexByString('D18'), TextCellValue('${porcentajes[1]}%'));
      sheet.updateCell(CellIndex.indexByString('E18'), TextCellValue(formattedIndirectosDeCampo));

      var formattedSubtotal1 = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(subtotal1);
      sheet.updateCell(CellIndex.indexByString('E19'), TextCellValue(formattedSubtotal1));

      var formattedFinanciamiento = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(financiamiento);
      sheet.updateCell(CellIndex.indexByString('D20'), TextCellValue('${porcentajes[2]}%'));
      sheet.updateCell(CellIndex.indexByString('E20'), TextCellValue(formattedFinanciamiento));

      var formattedSubtotal2 = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(subtotal2);
      sheet.updateCell(CellIndex.indexByString('E21'), TextCellValue(formattedSubtotal2));

      var formattedUtilidad = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(utilidad);
      sheet.updateCell(CellIndex.indexByString('D22'), TextCellValue('${porcentajes[3]}%'));
      sheet.updateCell(CellIndex.indexByString('E22'), TextCellValue(formattedUtilidad));

      var formattedSubtotal3 = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(subtotal3);
      sheet.updateCell(CellIndex.indexByString('E23'), TextCellValue(formattedSubtotal3));

      var formattedCargosAdicionales = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(cargosAdicionales);
      sheet.updateCell(CellIndex.indexByString('D24'), TextCellValue('${porcentajes[4]}%'));
      sheet.updateCell(CellIndex.indexByString('E24'), TextCellValue(formattedCargosAdicionales));

      var formattedSubtotal4 = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(subtotal4);
      sheet.updateCell(CellIndex.indexByString('E25'), TextCellValue(formattedSubtotal4));

      var formattedOtrosPorcentajes = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(otrosPorcentajes);
      sheet.updateCell(CellIndex.indexByString('D26'), TextCellValue('${porcentajes[5]}%'));
      sheet.updateCell(CellIndex.indexByString('E26'), TextCellValue(formattedOtrosPorcentajes));

      var formattedTotalIndirectos = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalIndirectos);
      sheet.updateCell(CellIndex.indexByString('E27'), TextCellValue(formattedTotalIndirectos));

      double roundedTotal = double.parse(presupuesto.total.toStringAsFixed(2));
      double roundedTotalIndirectos = double.parse(totalIndirectos.toStringAsFixed(2));

      var formattedFinal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(roundedTotal + roundedTotalIndirectos);
      sheet.updateCell(CellIndex.indexByString('E30'), TextCellValue(formattedFinal));

      String fileName = "";
      if (esPrivado) {
        fileName = '${presupuesto.nombre}_ConstruccionPrivada.xlsx';
      } else {
        fileName = '${presupuesto.nombre}_Construccion.xlsx';
      }
      String filePath = '$selectedDirectory/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(excel.encode()!, flush: true);

      // Guarda en Hive
      var detalle = ConstruccionDetalle(nombreArchivo: fileName, porcentajes: porcentajes);
      guardarDetalleConstruccion(presupuesto.nombre, detalle, esPrivado);

      _shareFile(filePath);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo Excel generado y listo para compartir')));
      MenuPage.menuPageKey.currentState?.openDrawerAndHighlightProyecto();
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

Future<void> guardarDetalleConstruccion(String nombre, ConstruccionDetalle detalle, bool esPrivado) async {
  var box = Hive.box<ConstruccionDetalle>(esPrivado ? 'construccionesPrivadas' : 'construcciones');
  await box.put(nombre, detalle);
}

List<PresupuestoDetalle> obtenerPresupuestos(String boxName) {
  var box = Hive.box<PresupuestoDetalle>(boxName);
  return box.values.toList();
}

ConstruccionDetalle? obtenerDetalleConstruccion(String nombrePresupuesto, bool esPrivado) {
  var box = Hive.box<ConstruccionDetalle>(esPrivado ? 'construccionesPrivadas' : 'construcciones');
  return box.get(nombrePresupuesto);
}
