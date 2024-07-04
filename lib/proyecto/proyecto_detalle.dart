// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'aspecto_proyecto.dart';
import 'ponderaciones.dart';
import 'dart:math' as math;

class ProyectoDetallePage extends StatefulWidget {
  final String nombre;

  const ProyectoDetallePage({super.key, required this.nombre});

  @override
  // ignore: library_private_types_in_public_api
  _ProyectoDetallePageState createState() => _ProyectoDetallePageState();
}

class _ProyectoDetallePageState extends State<ProyectoDetallePage> {
  int _menuIndex = 0;
  Map<String, List<String>> selectedOptions = {};
  late PresupuestoDetalle detalle;
  late ConstruccionDetalle detalleConstruccion;

  // Añadir la variable costosPorOpcion
  Map<String, double> costosPorOpcion = {};

  @override
  void initState() {
    super.initState();
    detalle = cargarPresupuesto(widget.nombre);
    detalleConstruccion = cargarConstruccion(widget.nombre);
  }

  @override
  Widget build(BuildContext context) {
    final aspecto = aspectosProyecto[_menuIndex];
    List<String> selected = selectedOptions.containsKey(aspecto.titulo)
        ? selectedOptions[aspecto.titulo]!
        : [];

    return Scaffold(
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
                  _showInputMetrosDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 76, 112, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                ),
                child: const Text(
                  'Confirmar',
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

  void _showInputMetrosDialog(BuildContext context) {
    String dialogTitle = 'Ingrese los Metros Cuadrados o Metros para ${detalle.opcion}';
    double valorDefault = obtenerValorPorOpcion(detalle.opcion);
    TextEditingController metrosController = TextEditingController(text: valorDefault.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: TextField(
            controller: metrosController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Metros cuadrados o metros',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onTap: () {
              metrosController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: metrosController.text.length,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                double metros = double.tryParse(metrosController.text) ?? valorDefault;
                if (metros == 0) {
                  metros = valorDefault;
                }
                Navigator.of(context).pop();
                _showConfirmationDialog(context, metros);  // Ahora pasamos los metros al siguiente diálogo
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, double metros) {
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
                Text('$metros m2'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        children: _generateSummaryText(metros),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
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
                guardarProyectoExcel(detalle, metros, selectedOptions);
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  double _calcularTotalFinal(double metros) {
    double factorRegional = 0.75;
    double honorarios = calcularHonorariosTotales(detalle.total, metros, detalleConstruccion.porcentajes, factorRegional);
    costosPorOpcion = calcularCostosPorOpcion(honorarios, selectedOptions);
    double totalFinal = 0.0;

    selectedOptions.forEach((titulo, opciones) {
      for (var opcion in opciones) {
        double costo = costosPorOpcion['$titulo - $opcion'] ?? 0;
        totalFinal += costo;
      }
    });

    return totalFinal;
  }

  List<TextSpan> _generateSummaryText(metros) {
    List<TextSpan> summaryText = [];
    var totalFinal = _calcularTotalFinal(metros);
    var formattedTotalFinal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalFinal);
    summaryText.add(TextSpan(text: "Total Alcances: $formattedTotalFinal\n", style: const TextStyle(fontWeight: FontWeight.bold)));
    selectedOptions.forEach((key, value) {
      if (value.isNotEmpty) {
        summaryText.add(TextSpan(text: "$key:\n", style: const TextStyle(fontWeight: FontWeight.bold)));
        for (var option in value) {
          String fullKey = '$key - $option';
          summaryText.add(TextSpan(text: '- $option: ${NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costosPorOpcion[fullKey])}\n'));
        }
      }
    });
    return summaryText;
  }

  Future<void> guardarProyectoExcel(PresupuestoDetalle detalle, double metros, Map<String, List<String>> selectedOptions) async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      openAppSettings();
      return;
    }

    status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se seleccionó un directorio.'),
          ),
        );
        return;
      }

      final ByteData data = await rootBundle.load("assets/plantillas/PROYECTO.xlsx");
      var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      var excel = Excel.decodeBytes(bytes);
      var sheet = excel['Hoja1'];

      sheet.updateCell(CellIndex.indexByString('C2'), TextCellValue(detalle.fechaEmision));
      sheet.updateCell(CellIndex.indexByString('F2'), TextCellValue(detalle.fechaCaducidad));
      sheet.updateCell(CellIndex.indexByString('C4'), TextCellValue(detalle.nombreEmpresa));
      sheet.updateCell(CellIndex.indexByString('F4'), TextCellValue(detalle.telefono));
      sheet.updateCell(CellIndex.indexByString('C5'), TextCellValue(detalle.domicilio));
      sheet.updateCell(CellIndex.indexByString('C6'), TextCellValue(detalle.correo));
      sheet.updateCell(CellIndex.indexByString('C8'), TextCellValue(detalle.contratista));
      sheet.updateCell(CellIndex.indexByString('F8'), TextCellValue(detalle.telefonoContratista));
      sheet.updateCell(CellIndex.indexByString('C9'), TextCellValue(detalle.nombre));
      sheet.updateCell(CellIndex.indexByString('F9'), TextCellValue(detalle.giroProyecto));
      sheet.updateCell(CellIndex.indexByString('C10'), TextCellValue(detalle.ubicacionProyecto));
      sheet.updateCell(CellIndex.indexByString('C11'), TextCellValue(detalle.descripcionProyecto));

      double factorRegional = 0.75;
      double honorarios = calcularHonorariosTotales(detalle.total, metros, detalleConstruccion.porcentajes, factorRegional);
      print(honorarios);
      costosPorOpcion = calcularCostosPorOpcion(honorarios, selectedOptions);
      double totalFinal = 0.0;

      int rowIndex = 15;  // Comenzar a escribir desde la línea 15
      selectedOptions.forEach((titulo, opciones) {
        // Combinar celdas de la A a la F y añadir título
        sheet.merge(CellIndex.indexByString('A$rowIndex'), CellIndex.indexByString('F$rowIndex'), customValue: TextCellValue(titulo));
        rowIndex++;  // Incrementar para la siguiente fila

        for (var opcion in opciones) {
          // Combinar celdas de la A a la D y añadir nombre de la opción
          sheet.merge(CellIndex.indexByString('A$rowIndex'), CellIndex.indexByString('D$rowIndex'), customValue: TextCellValue(opcion));
          // Combinar celdas de la E a la F y preparar espacio para el costo
          double costo = costosPorOpcion['$titulo - $opcion'] ?? 0;
          totalFinal += costo;
          var formattedCosto = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costo);
          sheet.merge(CellIndex.indexByString('E$rowIndex'), CellIndex.indexByString('F$rowIndex'), customValue: TextCellValue(formattedCosto));
          rowIndex++;  // Incrementar para la siguiente fila
        }
      });

      sheet.merge(CellIndex.indexByString('A$rowIndex'), CellIndex.indexByString('D$rowIndex'), customValue: const TextCellValue("TOTAL:"));
      var formattedFinal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalFinal);
      sheet.merge(CellIndex.indexByString('E$rowIndex'), CellIndex.indexByString('F$rowIndex'), customValue: TextCellValue(formattedFinal));

      String fileName = '${detalle.nombre}_Proyecto.xlsx';
      String filePath = '$selectedDirectory/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(excel.encode()!, flush: true);

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

double calcularCostoTotalAjustado(double costoBase, List<double> porcentajesAdicionales) {
  // Cálculo de indirectos con la nueva lógica
  costoBase = double.parse(costoBase.toStringAsFixed(2));
  double indirectosDeOficina = (costoBase * (porcentajesAdicionales[0] / 100));
  indirectosDeOficina = double.parse(indirectosDeOficina.toStringAsFixed(2));
  double indirectosDeCampo = (costoBase * (porcentajesAdicionales[1] / 100));
  indirectosDeCampo = double.parse(indirectosDeCampo.toStringAsFixed(2));
  double subtotal1 = indirectosDeOficina + indirectosDeCampo + costoBase;

  double financiamiento = (subtotal1 * (porcentajesAdicionales[2] / 100));
  financiamiento = double.parse(financiamiento.toStringAsFixed(2));
  double subtotal2 = subtotal1 + financiamiento;

  double utilidad = subtotal2 * (porcentajesAdicionales[3] / 100);
  utilidad = double.parse(utilidad.toStringAsFixed(2));
  double subtotal3 = subtotal2 + utilidad;

  double cargosAdicionales = subtotal3 * (porcentajesAdicionales[4] / 100);
  cargosAdicionales = double.parse(cargosAdicionales.toStringAsFixed(2));
  double subtotal4 = subtotal3 + cargosAdicionales;

  double otrosPorcentajes = subtotal4 * (porcentajesAdicionales[5] / 100);
  otrosPorcentajes = double.parse(otrosPorcentajes.toStringAsFixed(2));
  double totalIndirectos = indirectosDeOficina + indirectosDeCampo + financiamiento + utilidad + cargosAdicionales + otrosPorcentajes;
  totalIndirectos = double.parse(totalIndirectos.toStringAsFixed(2));

  double costoTotalAjustado = costoBase + totalIndirectos;
  return double.parse(costoTotalAjustado.toStringAsFixed(2));
}

double calcularCostoDirecto(double costoTotalAjustado, double metros) {
  double fc = 1.14;
  //print("CO: $costoTotalAjustado");
  //print(metros);
  return double.parse((costoTotalAjustado * metros * fc).toStringAsFixed(2));
}

double calcularFactorSuperficie(double metros) {
  return double.parse((15 - (2.5 * math.log(metros) / math.ln10)).toStringAsFixed(2));
}

double calcularHonorarios(double co, double fs, double fr) {
  return double.parse(((co * fs * fr) / 100).toStringAsFixed(2));
}

double calcularHonorariosTotales(double costoBase, double metros, List<double> porcentajesAdicionales, double fr) {
  double costoTotalAjustado = calcularCostoTotalAjustado(costoBase, porcentajesAdicionales) / metros;
  double co = calcularCostoDirecto(costoTotalAjustado, metros);
  double fs = calcularFactorSuperficie(metros);
  double honorarios = calcularHonorarios(co, fs, fr);
  //print('Costo total Ajustado: $costoTotalAjustado');
  //print('Costo por m2: $co');
  //print('Factor superficie: $fs');

  return honorarios;
}

Map<String, double> calcularCostosPorOpcion(double honorarios, Map<String, List<String>> selectedOptions) {
  Map<String, double> costosPorOpcion = {};

  for (var ponderacion in ponderaciones) {
    if (selectedOptions.containsKey(ponderacion.categoria)) {
      List<String> opcionesSeleccionadas = selectedOptions[ponderacion.categoria]!;
      //print('Categoría: ${ponderacion.categoria}, Porcentaje: ${ponderacion.porcentaje}');
      for (var subPonderacion in ponderacion.subPonderaciones) {
        if (opcionesSeleccionadas.contains(subPonderacion.nombre)) {
          double costo = honorarios * ponderacion.porcentaje * subPonderacion.porcentaje;
          String key = '${ponderacion.categoria} - ${subPonderacion.nombre}';
          costosPorOpcion[key] = costo;
         //print('  SubPonderación: ${subPonderacion.nombre}, Porcentaje: ${subPonderacion.porcentaje}');
         // print('    Opción seleccionada: ${subPonderacion.nombre}, Costo calculado: $costo');
        } else {
         // print('  SubPonderación no seleccionada: ${subPonderacion.nombre}, Porcentaje: ${subPonderacion.porcentaje}');
        }
      }
    }
  }

  //print('Costos por opción calculados: $costosPorOpcion');
  return costosPorOpcion;
}

PresupuestoDetalle cargarPresupuesto(String nombre) {
  var box = Hive.box<PresupuestoDetalle>('presupuestos');
  return box.get(nombre)!;
}

ConstruccionDetalle cargarConstruccion(String nombre) {
  var box = Hive.box<ConstruccionDetalle>('construcciones');
  return box.get(nombre)!;
}

double obtenerValorPorOpcion(String opcion) {
  String opcionNormalizada = opcion.toLowerCase().trim();

  if (opcionNormalizada.contains('cancha de usos múltiples con recubrimiento acrílico') && opcionNormalizada.contains('633.75 m2')) {
    return 633.75;
  } else if (opcionNormalizada.contains('cancha de usos múltiples sin recubrimiento acrílico') && opcionNormalizada.contains('633.75 m2')) {
    return 633.75;
  } else if (opcionNormalizada.contains('techado de cancha de usos múltiples') && opcionNormalizada.contains('751.08 m2')) {
    return 751.08;
  } else if (opcionNormalizada.contains('aula aislada') && opcionNormalizada.contains('74.52 m2')) {
    return 74.52;
  } else if (opcionNormalizada.contains('aula aislada') && opcionNormalizada.contains('6.00 x 8.00 mts')) {
    return 48.0;
  } else if (opcionNormalizada.contains('techado cancha de usos múltiples infraestructura educativa') && opcionNormalizada.contains('800 m2')) {
    return 800.0;
  } else if (opcionNormalizada.contains('umaps un consultorio')) {
    return 515.41;
  } else if (opcionNormalizada.contains('umaps dos consultorios')) {
    return 530.35;
  } else if (opcionNormalizada.contains('umaps tres consultorios')) {
    return 549.29;
  } else if (opcionNormalizada.contains('umaps cuatro consultorios')) {
    return 560.23;
  } else if (opcionNormalizada.contains('cancha de futbol siete') && opcionNormalizada.contains('34 x 54 m')) {
    return 1836.0;
  } else if (opcionNormalizada.contains('cancha de futbol soccer prácticas') && opcionNormalizada.contains('64.40 x 94.40 m')) {
    return 6079.36;
  } else if (opcionNormalizada.contains('gimnasio al aire libre') && opcionNormalizada.contains('64 m2')) {
    return 64.0;
  } else if (opcionNormalizada.contains('espacios públicos plaza') && opcionNormalizada.contains('1839 m2')) {
    return 1839.0;
  } else if (opcionNormalizada.contains('guarnición regular') && opcionNormalizada.contains('246.50 m')) {
    return 246.50;
  } else if (opcionNormalizada.contains('guarnición semi-integral') && opcionNormalizada.contains('235.47 m')) {
    return 235.47;
  } else if (opcionNormalizada.contains('barda perimetral') && opcionNormalizada.contains('18.20 m')) {
    return 18.20;
  } else if (opcionNormalizada.contains('línea de conducción') && opcionNormalizada.contains('14.49 m')) {
    return 14.49;
  } else if (opcionNormalizada.contains('línea de distribución') && opcionNormalizada.contains('7.95 m')) {
    return 7.95;
  } else {
    return 0.0;
  }
}
