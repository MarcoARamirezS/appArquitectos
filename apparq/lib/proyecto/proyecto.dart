import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:apparq/models/construccion_detalle.dart';
import 'package:apparq/models/presupuesto_detalle.dart';
import 'package:apparq/menu.dart';
import 'proyecto_detalle.dart';


class ProyectoPage extends StatefulWidget {
  const ProyectoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProyectoPageState createState() => _ProyectoPageState();
}

class _ProyectoPageState extends State<ProyectoPage> {
  List<PresupuestoDetalle> presupuestos = [];

  @override
  void initState() {
    super.initState();
    // Obtener la lista de presupuestos al iniciar el widget
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
            return ListTile(
              title: Text(presupuesto.nombre),
              onTap: () {
                if (MenuPage.menuPageKey.currentState != null) {
                      MenuPage.menuPageKey.currentState!.setPage(ProyectoDetallePage(nombre: presupuesto.nombre), presupuesto.nombre);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

List<PresupuestoDetalle> obtenerPresupuestosFiltrados() {
    var boxPresupuestos = Hive.box<PresupuestoDetalle>('presupuestos');
    var boxConstrucciones = Hive.box<ConstruccionDetalle>('construcciones');

    // Filtra y retorna solo los presupuestos que tienen un detalle de construcción correspondiente
    return boxPresupuestos.values.where((presupuesto) {
      return boxConstrucciones.containsKey(presupuesto.nombre);
    }).toList();
  }
