import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  VideoPlayerController? _controller;
  String selectedRegion = 'No region selected'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _loadSelectedRegion();
    _controller = VideoPlayerController.asset('assets/INICIO.mp4')
      ..initialize().then((_) {
        // Asegúrate de llamar a setState para que se reconstruya la vista
        setState(() {});
      });
    _controller?.play();
    _controller?.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
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
        child: _controller?.value.isInitialized ?? false
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : Text('Region Seleccionada: $selectedRegion'),
      ),
    );
  }
}
