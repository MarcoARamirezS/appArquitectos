import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, FilteringTextInputFormatter, rootBundle;
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

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  Future<void> loadCSV() async {
    final subcategoriaMayusculas = removeAccents(widget.subcategoriaSeleccionada.toUpperCase());
    final opcionMayusculas = removeAccents(widget.opcion.toUpperCase());
    String ruta = '${widget.categoriaSeleccionada}/$subcategoriaMayusculas/$opcionMayusculas/archivo.csv';

    try {
      final ByteData data = await rootBundle.load('assets/csv/$ruta');
      final List<int> bytes = data.buffer.asUint8List();
      final String csvString = utf8.decode(bytes);
      List<List<dynamic>> parsedCSV = const CsvToListConverter().convert(csvString);
      List<Categoria> tempCategoriasList = [];
      Categoria? categoriaActual;
      Subcat? subcategoriaActual;

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
            final precioString = row.isNotEmpty ? row[3].toString().replaceAll(',', '') : '0'; // Convertir a cadena
            final precio = double.tryParse(precioString) ?? 0;
            print(precioString);
            subcategoriaActual.productos.add(Producto(
              clave: codigo,
              nombre: nombre,
              unidad: unidad,
              precio: precio,
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
      appBar: AppBar(
        title: Text(widget.opcion),
      ),
      body: Column(
        children: [
          Expanded( // Expandir el ListView para que ocupe el espacio disponible
            child: Center(
              child: ListView.builder(
                itemCount: categoriasList.length,
                itemBuilder: (context, index) {
                  final categoria = categoriasList[index];
                  return ExpansionTile(
                    title: Text(categoria.nombre),
                    children: [
                      ...categoria.subcategorias.map((subcategoria) => ExpansionTile(
                        title: Text(subcategoria.nombre),
                        children: [
                          ...subcategoria.productos.map((producto) => Table(
                            border: TableBorder.all(),
                            columnWidths: const {
                              // Ancho de las columnas
                              0: FlexColumnWidth(3.1), // Columna del nombre
                              1: FlexColumnWidth(1), // Columna de la cantidad
                              2: FlexColumnWidth(0.7), // Columna de la unidad
                              3: FlexColumnWidth(1.2), // Columna del precio
                            },
                            children: [
                              TableRow(
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
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      initialValue: producto.cantidad.toString(),
                                      onChanged: (String valor) {
                                        setState(() {
                                          producto.cantidad = int.tryParse(valor) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(child: Text(producto.unidad)),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(child: Text('\$${producto.precio}')),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )).toList(),
                        ],
                      )).toList(),
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
                String resumen = generarResumenTicket();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Resumen del Presupuesto'),
                      content: SingleChildScrollView( // Envolver el contenido en SingleChildScrollView
                        child: Text(resumen),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              }, 
              child: Text('Acción'),
            ),
          ),
        ],
      ),
    );
  }

  String generarResumenTicket() {
    String resumen = '';
    double totalGeneral = 0.0;

    List<Categoria> categoriasConProductos = obtenerCategoriasConProductos();

    for (var categoria in categoriasConProductos) {
      for (var subcategoria in categoria.subcategorias) {
        for (var producto in subcategoria.productos) {
          if (producto.cantidad > 0) {
            double precioTotalProducto = producto.cantidad * producto.precio;
            resumen += '${producto.nombre} (${producto.cantidad} ${producto.unidad}) - \$${precioTotalProducto.toStringAsFixed(2)}\n';
            totalGeneral += precioTotalProducto;
          }
        }
      }
    }

    resumen += '\nTotal General: \$${totalGeneral.toStringAsFixed(2)}';
    return resumen;
  }

  List<Categoria> obtenerCategoriasConProductos() {
    return categoriasList.map((categoria) {
      // Filtrar subcategorías con productos con cantidad > 0
      List<Subcat> subcategoriasFiltradas = categoria.subcategorias
          .where((subcat) => subcat.productos.any((producto) => producto.cantidad > 0))
          .toList();

      // Crear nuevas subcategorías con productos filtrados
      subcategoriasFiltradas = subcategoriasFiltradas.map((subcat) {
        List<Producto> productosFiltrados =
            subcat.productos.where((producto) => producto.cantidad > 0).toList();
        return Subcat(nombre: subcat.nombre, productos: productosFiltrados);
      }).toList();

      // Crear nueva categoría con subcategorías filtradas
      return Categoria(nombre: categoria.nombre, subcategorias: subcategoriasFiltradas);
    }).toList();
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
  int cantidad;
  final double precio;

  Producto({
    required this.clave,
    required this.nombre,
    required this.unidad,
    required this.precio,
    this.cantidad = 0,
  });
}

void main() {
  runApp(const MaterialApp(
    home: PresSubcatPage(
      categoriaSeleccionada: 'Categoria',
      subcategoriaSeleccionada: 'Subcategoria',
      opcion: 'Opcion',
    ),
  ));
}

