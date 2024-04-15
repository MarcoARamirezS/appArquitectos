import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  String selectedRegion = 'No region selected'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _loadSelectedRegion();
  }

  Future<void> _loadSelectedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    String? region = prefs.getString('selected_region');
    if (region != null) {
      setState(() {
        selectedRegion = region;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Region Seleccionada: $selectedRegion'),
      ),
    );
  }
}