import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show ByteData, FilteringTextInputFormatter, rootBundle;
import 'dart:convert';

class PresSubcatPage extends StatefulWidget {
  final String categoriaSeleccionada;
  final String subcategoriaSeleccionada;
  final String opcion;
  final String selectedRegion;

  const PresSubcatPage({
    super.key,
    required this.categoriaSeleccionada,
    required this.subcategoriaSeleccionada,
    required this.opcion, 
    required this.selectedRegion,
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
            //print(precioString);
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
                          color: const Color(0xEEEEEEEE), // Para los tiles hijos, usa un gris un poco más oscuro
                          child: ExpansionTile(
                            iconColor: const Color(0xFF044C70),
                            collapsedIconColor: const Color(0xFF044C70),
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

  String generarResumenTicket() {
    String resumen = 'Resumen del Presupuesto\n\n';
    double totalGeneral = 0.0;

    List<Categoria?> categoriasConProductos = obtenerCategoriasConProductos();

    for (var categoria in categoriasConProductos) {
      resumen += 'Categoría: ${categoria?.nombre}\n';

      for (var subcategoria in categoria!.subcategorias) {
        resumen += '  - ${subcategoria.nombre}\n';

        for (var producto in subcategoria.productos) {
          double precioTotalProducto = producto.cantidad * producto.precio;
          totalGeneral += precioTotalProducto;
          resumen += '    * ${producto.nombre} (${producto.cantidad} ${producto.unidad}) - \$${precioTotalProducto.toStringAsFixed(2)}\n'; // Detalle del producto
        } 
      }

      resumen += '\n';
    }

    resumen += '\nTotal General: \$${totalGeneral.toStringAsFixed(2)}';
    return resumen;
  }

  List<Categoria?> obtenerCategoriasConProductos() {
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
      selectedRegion: '',
    ),
  ));
}

