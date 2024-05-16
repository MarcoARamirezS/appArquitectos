import 'package:apparq/splash.dart';
import 'package:flutter/material.dart';
import 'region_selection_page.dart';
import 'proyecto/proyecto.dart';
import 'tramite/tramite.dart';
import 'Construccion/construccion.dart';
import 'presupuesto/presupuesto.dart';
import 'dashboard.dart';

class MenuPage extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MenuPageState> menuPageKey = GlobalKey<_MenuPageState>();

  MenuPage({Key? key}) : super(key: menuPageKey);

  @override
  // ignore: library_private_types_in_public_api
  _MenuPageState createState() => _MenuPageState();
}
class _MenuPageState extends State<MenuPage> {
  String appBarTitle = "Inicio";
  Widget currentPage = const DashboardPage();
  List<NavigationState> navigationHistory = [];
  
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
              _buildMenuItem('Cambiar región', 'assets/icon_region.png', 1),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Presupuesto'),
                onTap: () {
                  _onSelectItem(2);
                },
              ),
              _buildMenuItem('Construcción', 'assets/icon_construction.png', 3),
              _buildMenuItem('Proyecto', 'assets/icon_project.png', 4),
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
        body: currentPage,
      ),
    );
  }
  ListTile _buildMenuItem(String title, String iconPath, int index) {
    return ListTile(
      leading: Image.asset(iconPath, width: 24, height: 24),
      title: Text(title),
      onTap: () => _onSelectItem(index),
    );
  }
}

class NavigationState {
  final Widget page;
  final String title;

  NavigationState(this.page, this.title);
}