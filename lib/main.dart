import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/presupuesto_detalle.dart';
import 'models/construccion_detalle.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PresupuestoDetalleAdapter());
  Hive.registerAdapter(ConstruccionDetalleAdapter());
  await Hive.openBox<PresupuestoDetalle>('presupuestos');
  await Hive.openBox<ConstruccionDetalle>('construcciones');
  await Hive.openBox<PresupuestoDetalle>('presupuestosPrivados');
  await Hive.openBox<ConstruccionDetalle>('construccionesPrivadas');

  await initializeDateFormatting('es', null);

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
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const SplashPage(),
    );
  }
}
