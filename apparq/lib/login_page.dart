import 'package:flutter/material.dart';
import 'region_selection_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'CALCULADORA DE OBRA',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Usuario:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese su usuario',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contraseña:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese su contraseña',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center, // Centra el siguiente widget
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar a la página de "Selecciona tu región"
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegionSelectionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 76, 112, 1), // Cambia el color a azul
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  ),
                  child: const Text(
                    'E N T R A R',
                    style: TextStyle(
                      color: Colors.white, // Cambia el color del texto a blanco
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}