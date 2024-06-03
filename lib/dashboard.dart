import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/INICIO.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
        _controller?.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _controller?.value.isInitialized ?? false
              ? VideoPlayer(_controller!)
              : const Center(child: CircularProgressIndicator()),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildTextContainer(
                  "¡BIENVENIDOS A LA REVOLUCIÓN EN LA GESTIÓN DE OBRAS!",
                  "Una herramienta imprescindible para el sector de la construcción: la Calculadora de Arquitectos. Podrán calcular con precisión y eficiencia.",
                ),
                const SizedBox(height: 20),
                _buildTextContainer(
                  "OFRECEMOS",
                  "• Cálculo de presupuesto\n    ○ Obra pública\n    ○ Obra privada\n• Cálculo de construcción\n• Cálculo de proyecto",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContainer(String title, String content) {
    double width = MediaQuery.of(context).size.width * 1; // 80% de la anchura de la pantalla
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.70),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}