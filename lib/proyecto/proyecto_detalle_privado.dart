// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/services.dart';

class ProyectoDetallePrivadoPage extends StatefulWidget {
  final String nombre;

  const ProyectoDetallePrivadoPage({super.key, required this.nombre});
  
  @override
  _ProyectoDetallePrivadoPage createState() => _ProyectoDetallePrivadoPage();
}

class _ProyectoDetallePrivadoPage extends State<ProyectoDetallePrivadoPage> {
  final List<String> alcances = [
    'Diseño conceptual, dictámenes y gestión',
    'Anteproyecto arquitectónico y renders',
    'Diseño básico ejecutivo arquitectónicos, memorias',
    'Detalles, acabados, albañilería, cancelería, herrería, carpintería',
    'Estructura, planos y memoria de cálculo',
    'Instalación eléctrica, planos y memorias de cálculo',
    'Instalación hidráulica, planos y memorias de cálculo',
    'Instalación sanitaria, planos y memorias de cálculo',
    'Instalación de gas, planos y memorias de cálculo',
    'Catálogo, volumetrías y precio base',
  ];

  final Map<String, double> porcentajes = {
    'Diseño conceptual, dictámenes y gestión': 0.05,
    'Anteproyecto arquitectónico y renders': 0.20,
    'Diseño básico ejecutivo arquitectónicos, memorias': 0.30,
    'Detalles, acabados, albañilería, cancelería, herrería, carpintería': 0.10,
    'Estructura, planos y memoria de cálculo': 0.15,
    'Instalación eléctrica, planos y memorias de cálculo': 0.03,
    'Instalación hidráulica, planos y memorias de cálculo': 0.03,
    'Instalación sanitaria, planos y memorias de cálculo': 0.03,
    'Instalación de gas, planos y memorias de cálculo': 0.01,
    'Catálogo, volumetrías y precio base': 0.10,
  };

  final List<bool> selectedAlcances = List<bool>.filled(10, false);
  String? selectedImage;

  final Map<String, double> nivelValores = {
    'assets/proyectoPrivada/nivel_1.png': 0.10,
    'assets/proyectoPrivada/nivel_2.png': 0.25,
    'assets/proyectoPrivada/nivel_3.png': 0.50,
    'assets/proyectoPrivada/nivel_4.png': 0.75,
    'assets/proyectoPrivada/nivel_5.png': 1.00,
  };

  Map<String, double> descuentos = {};
  Map<String, double> alcancesCostos = {};
  Map<String, double> totalCostos = {};

  bool get isGuardarEnabled {
    return selectedAlcances.contains(true) && selectedImage != null;
  }

  bool incluirSupervision = false;
  bool incluirDisenoUrbano = false;
  bool incluirFirmaPerito = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Proyecto: ${widget.nombre}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Qué alcances tendrá?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...alcances.map((alcance) {
              int index = alcances.indexOf(alcance);
              return CheckboxListTile(
                title: Text(alcance),
                value: selectedAlcances[index],
                onChanged: (bool? value) {
                  setState(() {
                    selectedAlcances[index] = value ?? false;
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Nivel de desarrollo a trabajar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                String image = 'assets/proyectoPrivada/nivel_${index + 1}.png';
                String title = '';
                switch (index) {
                  case 0:
                    title = 'LOD 50';
                    break;
                  case 1:
                    title = 'LOD 100';
                    break;
                  case 2:
                    title = 'LOD 200';
                    break;
                  case 3:
                    title = 'LOD 250';
                    break;
                }
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = image;
                    });
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImage == image ? Colors.blue : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Image.asset(
                            image,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImage = 'assets/proyectoPrivada/nivel_5.png';
                  });
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedImage == 'assets/proyectoPrivada/nivel_5.png' ? Colors.blue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Image.asset(
                        'assets/proyectoPrivada/nivel_5.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'LOD 300',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Incluir servicios adicionales?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Supervisión (2% del costo de construcción)'),
              value: incluirSupervision,
              onChanged: (bool? value) {
                setState(() {
                  incluirSupervision = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Diseño Urbano (4% del costo de construcción)'),
              value: incluirDisenoUrbano,
              onChanged: (bool? value) {
                setState(() {
                  incluirDisenoUrbano = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Firma de Perito de Obra (0.8% del costo de construcción)'),
              value: incluirFirmaPerito,
              onChanged: (bool? value) {
                setState(() {
                  incluirFirmaPerito = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF044C70),
              ),
              onPressed: isGuardarEnabled ? _calcularCostos : null,
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  void _calcularCostos() async {
    var boxPresupuestos = await Hive.openBox<PresupuestoDetalle>('presupuestosPrivados');
    var boxConstrucciones = await Hive.openBox<ConstruccionDetalle>('construccionesPrivadas');

    final presupuesto = boxPresupuestos.get(widget.nombre);
    final construccion = boxConstrucciones.get(widget.nombre);

    if (presupuesto == null || construccion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontraron datos del proyecto.')),
      );
      return;
    }

    double costoConstruccion = presupuesto.total;
    double porcentajeServicios = 0.03;
    double costoTotal = 0.0;
    double costoServicios = 0.0;
    double nivelValor = nivelValores[selectedImage ?? 'assets/proyectoPrivada/nivel_1.png'] ?? 1.00;

    alcancesCostos = {};
    totalCostos = {};
    descuentos = {};

    for (var porcentaje in construccion.porcentajes) {
      costoTotal += costoConstruccion * (porcentaje / 100);
    }
    costoTotal += costoConstruccion;
    double costoTotalConstruccion = costoTotal;
    costoServicios = costoTotal * porcentajeServicios * nivelValor;
    costoTotal=0;

    selectedAlcances.asMap().forEach((index, isSelected) {
      if (isSelected) {
        double porcentaje = porcentajes[alcances[index]] ?? 0.0;
        double alcanceCosto = costoServicios * porcentaje;
        alcancesCostos[alcances[index]] = alcanceCosto;
        totalCostos[alcances[index]] = alcanceCosto;
        costoTotal += alcanceCosto;
      }
    });

    if (incluirSupervision) {
      double supervisionCosto = costoTotalConstruccion * 0.02;
      alcancesCostos['Supervisión'] = supervisionCosto;
      totalCostos['Supervisión'] = supervisionCosto;
      costoTotal += supervisionCosto;
    }
    if (incluirDisenoUrbano) {
      double disenoUrbanoCosto = costoTotalConstruccion * 0.04;
      alcancesCostos['Diseño Urbano'] = disenoUrbanoCosto;
      totalCostos['Diseño Urbano'] = disenoUrbanoCosto;
      costoTotal += disenoUrbanoCosto;
    }
    if (incluirFirmaPerito) {
      double firmaPeritoCosto = costoTotalConstruccion * 0.008;
      alcancesCostos['Firma de Perito de Obra'] = firmaPeritoCosto;
      totalCostos['Firma de Perito de Obra'] = firmaPeritoCosto;
      costoTotal += firmaPeritoCosto;
    }

    _mostrarResumenProyecto(presupuesto, alcancesCostos, totalCostos, costoTotal, costoTotalConstruccion);
  }

  void _mostrarResumenProyecto(PresupuestoDetalle presupuesto, Map<String, double> alcancesCostos, Map<String, double> totalCostos, double costoTotal, double costoTotalConstruccion) {
    String formattedCostoTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costoTotal+costoTotalConstruccion);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resumen del Proyecto'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Costo Total: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      TextSpan(
                        text: formattedCostoTotal,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Desglose de costos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...alcancesCostos.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(entry.value),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditarCostos(context, presupuesto, alcancesCostos, totalCostos, costoTotalConstruccion);
              },
              child: const Text('Editar Costos'),
            ),
            TextButton(
              onPressed: () {
                _handleSaveAndShare(presupuesto, alcancesCostos);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _navigateToEditarCostos(BuildContext context, PresupuestoDetalle presupuesto, Map<String, double> alcancesCostos, Map<String, double> totalCostos, double costoTotalConstruccion) async {
    final result = await Navigator.push<Map<String, Map<String, double>>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCostosPage(
          presupuesto: presupuesto,
          alcancesCostos: alcancesCostos,
          totalCostos: totalCostos,
          descuentos: descuentos, // Pasar los descuentos actuales
        ),
      ),
    );

    if (result != null) {
      setState(() {
        alcancesCostos.addAll(result['nuevosCostos']!);
        descuentos = result['descuentos']!; // Actualizar los descuentos
        _mostrarResumenProyecto(presupuesto, alcancesCostos, totalCostos, alcancesCostos.values.fold(0.0, (sum, value) => sum + value), costoTotalConstruccion);
      });
    }
  }


  Future<void> _handleSaveAndShare(PresupuestoDetalle presupuesto, Map<String, double> alcancesCostos) async {
    if (await _checkAndRequestPermissions()) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se seleccionó un directorio.')));
        return;
      }

      String? filePath = await _generateExcel(presupuesto, alcancesCostos, selectedDirectory);

      if (filePath != null) {
        _shareFile(filePath);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archivo Excel generado y listo para compartir')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al generar el archivo.')));
      }
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso denegado. No se pudo guardar el archivo.')));
    }
  }

  Future<String?> _generateExcel(PresupuestoDetalle presupuesto, Map<String, double> alcancesCostos, String selectedDirectory) async {
    final ByteData data = await rootBundle.load("assets/plantillas/PROYECTO.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel['Hoja1'];

    // Actualizar la hoja de cálculo con los datos del presupuesto y los alcances
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

    // Agregar los costos de los alcances
    int rowIndex = 15;
    double costoAlcances = 0.0;
    alcancesCostos.forEach((alcance, costo) {
      costoAlcances += costo;
      var formattedCosto = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costo);
      sheet.merge(CellIndex.indexByString('A$rowIndex'), CellIndex.indexByString('D$rowIndex'), customValue: TextCellValue(alcance));
      sheet.merge(CellIndex.indexByString('E$rowIndex'), CellIndex.indexByString('F$rowIndex'), customValue: TextCellValue(formattedCosto));
      rowIndex++;
    });

    var formattedCostoTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(costoAlcances);
    sheet.updateCell(CellIndex.indexByString('D$rowIndex'), const TextCellValue('TOTAL:'));
    sheet.merge(CellIndex.indexByString('E$rowIndex'), CellIndex.indexByString('F$rowIndex'), customValue: TextCellValue(formattedCostoTotal));

    // Guardar el archivo
    String fileName = '${presupuesto.nombre}_ProyectoPrivado.xlsx';
    String filePath = '$selectedDirectory/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(excel.encode()!, flush: true);

    return filePath;
  }

  Future<bool> _checkAndRequestPermissions() async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      openAppSettings();
    }
    return status.isGranted;
  }

  void _shareFile(String filePath) {
    Share.shareXFiles([XFile(filePath)], text: 'Aquí tienes el archivo del proyecto privado.');
  }
}

class EditarCostosPage extends StatefulWidget {
  final PresupuestoDetalle presupuesto;
  final Map<String, double> alcancesCostos;
  final Map<String, double> totalCostos;
  final Map<String, double> descuentos;

  const EditarCostosPage({
    super.key,
    required this.presupuesto,
    required this.alcancesCostos,
    required this.totalCostos,
    required this.descuentos,
  });

  @override
  _EditarCostosPageState createState() => _EditarCostosPageState();
}

class _EditarCostosPageState extends State<EditarCostosPage> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, ValueNotifier<double>> _notifiers = {};

  @override
  void initState() {
    super.initState();
    widget.alcancesCostos.forEach((key, value) {
      double descuento = widget.descuentos[key] ?? 0;
      _controllers[key] = TextEditingController(text: descuento.toString());
      _notifiers[key] = ValueNotifier<double>(widget.totalCostos[key]! * (1 - descuento / 100));
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _notifiers.values.forEach((notifier) => notifier.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Costos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Ingrese los porcentajes de descuento para cada aspecto del proyecto:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: widget.alcancesCostos.keys.map((key) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                key,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              child: TextFormField(
                                controller: _controllers[key],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Descuento %',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  double descuento = double.tryParse(value) ?? 0;
                                  double nuevoValor = widget.totalCostos[key]! * (1 - descuento / 100);
                                  _notifiers[key]?.value = nuevoValor;
                                  setState(() {});
                                },
                                onTap: () {
                                  _controllers[key]?.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _controllers[key]!.text.length,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder<double>(
                          valueListenable: _notifiers[key]!,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total: ${NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(value)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Map<String, ValueNotifier<double>>>(
              valueListenable: ValueNotifier(_notifiers),
              builder: (context, notifiers, child) {
                double total = notifiers.values.fold(0.0, (sum, notifier) => sum + notifier.value);
                return Text(
                  'Costo total de servicios después de aplicar descuentos: ${NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarCostos,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarCostos() {
    Map<String, double> nuevosCostos = {};
    Map<String, double> descuentos = {};
    widget.alcancesCostos.forEach((key, value) {
      double descuento = double.tryParse(_controllers[key]?.text ?? '0') ?? 0;
      nuevosCostos[key] = widget.totalCostos[key]! * (1 - descuento / 100);
      descuentos[key] = descuento;
    });

    Navigator.pop(context, {
      'nuevosCostos': nuevosCostos,
      'descuentos': descuentos,
    });
  }

}
