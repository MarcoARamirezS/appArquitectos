import 'package:flutter/material.dart';
import 'region_selection_page.dart';
import 'proyecto/proyecto.dart';
import 'tramite/tramite.dart';
import 'Construccion/construccion.dart';
import 'presupuesto/presupuesto.dart';
import 'dashboard.dart';

class MenuPage extends StatefulWidget {
  static final GlobalKey<_MenuPageState> menuPageKey = GlobalKey<_MenuPageState>();

  MenuPage({Key? key}) : super(key: menuPageKey);

  @override
  _MenuPageState createState() => _MenuPageState();
}
class _MenuPageState extends State<MenuPage> {
  String appBarTitle = "Dashboard";
  Widget currentPage = DashboardPage();
  List<NavigationState> navigationHistory = [];
  
  final List<Widget> _pages = [
    DashboardPage(),
    PresupuestoPage(),
    ConstruccionPage(),
    ProyectoPage(),
    TramitePage(),
    RegionSelectionPage(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Presupuesto",
    "Construcción",
    "Proyecto",
    "Trámite",
    "Cambiar región",
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
              // Aquí podrías poner información del usuario si es necesario
              accountName: Text("Nombre del Usuario"),
              accountEmail: Text("usuario@ejemplo.com"),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                _onSelectItem(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Presupuesto'),
              onTap: () {
                _onSelectItem(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Construcción'),
              onTap: () {
                _onSelectItem(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_tree),
              title: Text('Proyecto'),
              onTap: () {
                _onSelectItem(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.content_paste),
              title: Text('Trámite'),
              onTap: () {
                //_onSelectItem(4);
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Cambiar región'),
              onTap: () {
                _onSelectItem(5);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Cerrar sesión'),
              onTap: () {
                // Aquí podrías manejar el cierre de sesión
              },
            ),
          ],
          ),
        ),
        body: currentPage,
      ),
    );
  }
}

class NavigationState {
  final Widget page;
  final String title;

  NavigationState(this.page, this.title);
}