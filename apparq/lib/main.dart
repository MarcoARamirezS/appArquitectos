import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';
import 'models/presupuesto_detalle.dart';
import 'models/construccion_detalle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PresupuestoDetalleAdapter());
  Hive.registerAdapter(ConstruccionDetalleAdapter());
  await Hive.openBox<PresupuestoDetalle>('presupuestos');
  await Hive.openBox<ConstruccionDetalle>('construcciones');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), 
    );
  }
}