import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:apparq/menu.dart';
import 'proyecto_detalle.dart';

class ProyectoPage extends StatefulWidget {
  const ProyectoPage({super.key});

  @override
  _ProyectoPageState createState() => _ProyectoPageState();
}

class _ProyectoPageState extends State<ProyectoPage> {
  List<PresupuestoDetalle> presupuestos = [];

  @override
  void initState() {
    super.initState();
    presupuestos = obtenerPresupuestosFiltrados();
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
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!)
                )
              ),
              child: ListTile(
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
                  onPressed: () => _borrarConstruccion(presupuesto.nombre),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _borrarConstruccion(String nombre) async {
    bool confirm = await _mostrarDialogoDeConfirmacion(context, nombre);
    if (confirm) {
      var boxConstrucciones = Hive.box<ConstruccionDetalle>('construcciones');
      boxConstrucciones.delete(nombre);
      // Actualiza la UI tras borrar el elemento
      setState(() {
        presupuestos = obtenerPresupuestosFiltrados();
      });
    }
  }

  Future<bool> _mostrarDialogoDeConfirmacion(BuildContext context, String nombre) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar los datos de la construccion: "$nombre"?'),
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

List<PresupuestoDetalle> obtenerPresupuestosFiltrados() {
    var boxPresupuestos = Hive.box<PresupuestoDetalle>('presupuestos');
    var boxConstrucciones = Hive.box<ConstruccionDetalle>('construcciones');
    return boxPresupuestos.values.where((presupuesto) {
      return boxConstrucciones.containsKey(presupuesto.nombre);
    }).toList();
}
