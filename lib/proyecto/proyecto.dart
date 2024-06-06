import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:apparq/menu.dart';
import 'proyecto_detalle.dart';
import 'proyecto_detalle_privado.dart'; // Página que se debe crear para detalles de proyectos privados

class ProyectoPage extends StatefulWidget {
  const ProyectoPage({super.key});

  @override
  _ProyectoPageState createState() => _ProyectoPageState();
}

class _ProyectoPageState extends State<ProyectoPage> {
  List<PresupuestoDetalle> presupuestosPublicos = [];
  List<PresupuestoDetalle> presupuestosPrivados = [];

  @override
  void initState() {
    super.initState();
    presupuestosPublicos = obtenerPresupuestosFiltrados('presupuestos', 'construcciones');
    presupuestosPrivados = obtenerPresupuestosFiltrados('presupuestosPrivados', 'construccionesPrivadas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            ExpansionTile(
              title: const Text('Proyectos Públicos'),
              children: presupuestosPublicos.map((presupuesto) {
                return ListTile(
                  title: Text(presupuesto.nombre),
                  onTap: () {
                    if (MenuPage.menuPageKey.currentState != null) {
                      MenuPage.menuPageKey.currentState!.setPage(
                        ProyectoDetallePage(nombre: presupuesto.nombre),
                        presupuesto.nombre
                      );
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _borrarConstruccion(presupuesto.nombre, false),
                  ),
                );
              }).toList(),
            ),
            ExpansionTile(
              title: const Text('Proyectos Privados'),
              children: presupuestosPrivados.map((presupuesto) {
                return ListTile(
                  title: Text(presupuesto.nombre),
                  onTap: () {
                    if (MenuPage.menuPageKey.currentState != null) {
                      MenuPage.menuPageKey.currentState!.setPage(
                        ProyectoDetallePrivadoPage(nombre: presupuesto.nombre), // Página específica para privados
                        presupuesto.nombre
                      );
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _borrarConstruccion(presupuesto.nombre, true),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _borrarConstruccion(String nombre, bool esPrivado) async {
    bool confirm = await _mostrarDialogoDeConfirmacion(context, nombre);
    if (confirm) {
      var boxConstrucciones = Hive.box<ConstruccionDetalle>(esPrivado ? 'construccionesPrivadas' : 'construcciones');
      boxConstrucciones.delete(nombre);
      // Actualiza la UI tras borrar el elemento
      setState(() {
        if (esPrivado) {
          presupuestosPrivados = obtenerPresupuestosFiltrados('presupuestosPrivados', 'construccionesPrivadas');
        } else {
          presupuestosPublicos = obtenerPresupuestosFiltrados('presupuestos', 'construcciones');
        }
      });
    }
  }

  Future<bool> _mostrarDialogoDeConfirmacion(BuildContext context, String nombre) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar los datos de la construcción: "$nombre"?'),
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
  }
}

List<PresupuestoDetalle> obtenerPresupuestosFiltrados(String boxPresupuestosName, String boxConstruccionesName) {
    var boxPresupuestos = Hive.box<PresupuestoDetalle>(boxPresupuestosName);
    var boxConstrucciones = Hive.box<ConstruccionDetalle>(boxConstruccionesName);
    return boxPresupuestos.values.where((presupuesto) {
      return boxConstrucciones.containsKey(presupuesto.nombre);
    }).toList();
}