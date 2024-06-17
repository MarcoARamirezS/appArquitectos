// ignore_for_file: avoid_print

import 'package:apparq/splash.dart';
import 'package:flutter/material.dart';
import 'region_selection_page.dart';
import 'proyecto/proyecto.dart';
import 'tramite/tramite.dart';
import 'Construccion/construccion.dart';
import 'presupuesto/presupuesto.dart';
import 'dashboard.dart';
import 'package:hive/hive.dart';
import 'models/presupuesto_detalle.dart';
import 'models/construccion_detalle.dart';

class MenuPage extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MenuPageState> menuPageKey = GlobalKey<_MenuPageState>();

  MenuPage({Key? key}) : super(key: menuPageKey);

  @override
  // ignore: library_private_types_in_public_api
  _MenuPageState createState() => _MenuPageState();
}
class _MenuPageState extends State<MenuPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  String appBarTitle = "Inicio";
  Widget currentPage = const DashboardPage();
  List<NavigationState> navigationHistory = [];
  bool hasPresupuesto = false;
  bool hasConstruccion = false;
  final GlobalKey _regionTileKey = GlobalKey();
  //bool _isFlashing = false;

  @override
  void initState() {
    super.initState();
    _checkAvailableData();
  }
  
  final List<Widget> _pages = [
    const DashboardPage(),
    const RegionSelectionPage(),
    const PresupuestoPage(),
    const ConstruccionPage(),
    const ProyectoPage(),
    const TramitePage(),
  ];

  final List<String> _titles = [
    "Inicio",
    "Cambiar región",
    "Presupuesto",
    "Construcción",
    "Proyecto",
    "Trámite",
  ];

  void setPage(Widget page, String title) {
    setState(() {
      navigationHistory.add(NavigationState(currentPage, appBarTitle));
      appBarTitle = title;
      currentPage = page;
    });
  }

  void _onSelectItem(int index) {
    Navigator.pop(context);
    setState(() {
      navigationHistory.add(NavigationState(currentPage, appBarTitle));
      appBarTitle = _titles[index];
      currentPage = _pages[index];
    });
  }

  Future<bool> _onWillPop() async {
    if (navigationHistory.isNotEmpty) {
      NavigationState lastState = navigationHistory.removeLast();
      setState(() {
        print('Pagina ${lastState.page}');
        print('Titulo ${lastState.title}');
        currentPage = lastState.page;
        appBarTitle = lastState.title;
      });
      return false; // Evita que se cierre la app
    }
    return true; // Permite cerrar la app si la historia está vacía
  }

  void _flashRegionTile() {
    // Método para hacer parpadear el ListTile
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_regionTileKey.currentState != null) {
        setState(() {
          // Cambiar el estado del ListTile para que parpadee
        });
      }
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              const UserAccountsDrawerHeader(
                accountName: Text("Nombre del Usuario"),
                accountEmail: Text("usuario@ejemplo.com"),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Inicio'),
                onTap: () {
                  _onSelectItem(0);
                },
              ),
              _buildMenuItem('Cambiar región', 'assets/icon_region.png', 1, key: _regionTileKey), // Usar el GlobalKey
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Presupuesto'),
                onTap: () {
                  _onSelectItem(2);
                },
              ),
              ListTile(
                leading: Image.asset('assets/icon_construction.png', width: 24, height: 24),
                title: const Text('Construcción'),
                onTap: hasPresupuesto ? () => _onSelectItem(3) : null,
              ),
              ListTile(
                leading: Image.asset('assets/icon_project.png', width: 24, height: 24),
                title: const Text('Proyecto'),
                onTap: hasConstruccion ? () => _onSelectItem(4) : null,
              ),
              ListTile(
                leading: const Icon(Icons.content_paste),
                title: const Text('Trámite'),
                onTap: () {
                  //_onSelectItem(5);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashPage()),
                  );
                },
              ),
            ],
          ),
        ),
        onDrawerChanged: (isOpen) {
          if (isOpen) {
            _checkAvailableData(); // Se llama cuando el drawer se abre
            _flashRegionTile(); // Hacer parpadear el ListTile de "Cambiar región" cuando el drawer se abre
          }
        },
        body: currentPage,
      ),
    );
  }
  ListTile _buildMenuItem(String title, String iconPath, int index, {Key? key}) {
    return ListTile(
      key: key,
      leading: Image.asset(iconPath, width: 24, height: 24),
      title: Text(title),
      onTap: () => _onSelectItem(index),
    );
  }

  Future<void> _checkAvailableData() async {
    final presupuestoBox = Hive.box<PresupuestoDetalle>('presupuestos');
    final construccionBox = Hive.box<ConstruccionDetalle>('construcciones');
    final presupuestoPrivadoBox = Hive.box<PresupuestoDetalle>('presupuestosPrivados');
    final construccionPrivadasBox = Hive.box<ConstruccionDetalle>('construccionesPrivadas');

    setState(() {
      hasPresupuesto = presupuestoBox.isNotEmpty || presupuestoPrivadoBox.isNotEmpty;
      hasConstruccion = (construccionBox.isNotEmpty || construccionPrivadasBox.isNotEmpty) && hasPresupuesto;
    });
  }
}

class NavigationState {
  final Widget page;
  final String title;

  NavigationState(this.page, this.title);
}