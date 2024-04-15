import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, FilteringTextInputFormatter, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'dart:convert';

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
            print('codigo: $codigo');
            final precio = double.tryParse(precioString) ?? 0;
            
            final cantidadString = row.isNotEmpty ? row[3].toString().replaceAll(',', '') : '0';
            print('CantidadString: $cantidadString');
            final cantidad = double.tryParse(cantidadString) ?? 0;
            print('Cantidad: $cantidad');
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
    } catch (e) {
      print('Error al cargar el archivo CSV: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                    backgroundColor: const Color(0xFF6C6F72),
                    title: Text(categoria.nombre),
                    children: [
                      ...categoria.subcategorias.map(
                        (subcategoria) => Container(
                          color: const Color(0xEEEEEEEE),
                          child: ExpansionTile(
                            iconColor: const Color(0xFF044C70),
                            collapsedIconColor: const Color(0xFF044C70),
                            title: Text(subcategoria.nombre),
                            children: [
                              Table(
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
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none, 
                                            contentPadding: EdgeInsets.all(3.0),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                          ],
                                          textAlign: TextAlign.center,
                                          initialValue: producto.cantidad.toString(),
                                          onChanged: (String valor) {
                                            setState(() {
                                              producto.cantidad = double.tryParse(valor) ?? 0;
                                            });
                                          },
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
                                  )).toList(),
                                ],
                              )
                            ],
                          ),
                        )
                      ).toList(),
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
                        child: RichText(
                          text: generarResumenTicket(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
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

  TextSpan generarResumenTicket() {
    List<TextSpan> children = [
      const TextSpan(text: 'Resumen del Presupuesto\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
    ];

    double totalGeneral = 0.0;
    List<Categoria?> categoriasConProductos = obtenerCategoriasConProductos();

    for (var categoria in categoriasConProductos) {
      children.add(
        TextSpan(text: 'Categoría: ${categoria?.nombre}\n', style: const TextStyle(fontWeight: FontWeight.bold))
      );

      for (var subcategoria in categoria!.subcategorias) {
        children.add(TextSpan(text: '  - ${subcategoria.nombre}\n'));

        for (var producto in subcategoria.productos) {
          double precioTotalProducto = producto.cantidad * producto.precio;
          totalGeneral += precioTotalProducto;
          children.add(TextSpan(text: '    * ${producto.nombre} (${producto.cantidad} ${producto.unidad}) - \$${precioTotalProducto.toStringAsFixed(2)}\n'));
        }
      }

      children.add(const TextSpan(text: '\n'));
    }

    final formattedTotal = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(totalGeneral);

    children.add(TextSpan(
      text: 'Total General: $formattedTotal',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ));

    return TextSpan(style: const TextStyle(fontSize: 16, color: Colors.black), children: children);
  }



  List<Categoria?> obtenerCategoriasConProductos() {
    return categoriasList.map((categoria) {
      // Filtrar subcategorÃ­as con productos con cantidad > 0
      List<Subcat> subcategoriasFiltradas = categoria.subcategorias
          .where((subcat) => subcat.productos.any((producto) => producto.cantidad > 0))
          .toList();

      // Crear nuevas subcategorÃ­as con productos filtrados
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

  Producto({
    required this.clave,
    required this.nombre,
    required this.unidad,
    required this.precio,
    required this.cantidad,
  });
}