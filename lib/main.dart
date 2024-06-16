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
      title: 'AppARQ',
      theme: ThemeData(
        primaryColor: const Color(0xFF044C70),
        hintColor: const Color(0xFF090A0C),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF044C70),
          secondary: Color(0xFF090A0C),
          background: Color(0xFFFFFFFF),
          surface: Color(0xFFEEEEEE),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF044C70), fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Color(0xFF6C6F72), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF090A0C)),
          bodyMedium: TextStyle(color: Color(0xFF090A0C)),
        ),
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
