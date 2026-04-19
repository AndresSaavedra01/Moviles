import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

///Función para Isolate
void _heavyTask(SendPort sendPort) {
  int total = 0;
  for (int i = 0; i < 1000000000; i++) {
    total += i;
  }
  // Enviamos el resultado de vuelta al hilo principal
  sendPort.send(total);
}

class TallerAsincroniaScreen extends StatefulWidget {
  const TallerAsincroniaScreen({super.key});

  @override
  State<TallerAsincroniaScreen> createState() => _TallerAsincroniaScreenState();
}

class _TallerAsincroniaScreenState extends State<TallerAsincroniaScreen> {
  // --- Estado Módulo Future ---
  String _futureStatus = "Esperando acción";
  bool _isFutureLoading = false;

  // --- Estado Módulo Timer ---
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  // --- Estado Módulo Isolate ---
  bool _isIsolateRunning = false;
  String _isolateResult = "Sin calcular";

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Lógica Future ---
  Future<void> _simulateApiCall() async {
    debugPrint("Flujo: Antes de la ejecución");
    setState(() {
      _isFutureLoading = true;
      _futureStatus = "Cargando...";
    });

    debugPrint("Flujo: Durante la ejecución (Future.delayed)");
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isFutureLoading = false;
        _futureStatus = "Éxito: Datos obtenidos";
      });
      debugPrint("Flujo: Después de la ejecución");
    }
  }

  // --- Lógica Timer ---
  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    }
    setState(() => _isTimerRunning = !_isTimerRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isTimerRunning = false;
    });
  }

  // --- Lógica Isolate ---
  Future<void> _runIsolateTask() async {
    setState(() {
      _isIsolateRunning = true;
      _isolateResult = "Calculando en 2do plano...";
    });

    // Puerto para recibir la respuesta del Isolate
    final receivePort = ReceivePort();

    // Spawning del Isolate: el hilo principal sigue libre para el cronómetro
    await Isolate.spawn(_heavyTask, receivePort.sendPort);

    // Escuchamos el primer mensaje (el resultado)
    receivePort.listen((message) {
      if (mounted) {
        setState(() {
          _isolateResult = "Resultado: $message";
          _isIsolateRunning = false;
        });
      }
      receivePort.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFFF5F5F7);
    const TextStyle headerStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87
    );

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("Asincronía en Flutter", style: TextStyle(color: Colors.black87)),
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Módulo 1: Future
              _buildCard(
                title: "Módulo Future (Async/Wait)",
                child: Column(
                  children: [
                    _isFutureLoading
                        ? const CircularProgressIndicator.adaptive()
                        : Text(_futureStatus, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildButton(
                      label: "Simular API",
                      onPressed: _isFutureLoading ? null : _simulateApiCall,
                      icon: Icons.cloud_download_outlined,
                    ),
                  ],
                ),
              ),

              // Módulo 2: Timer
              _buildCard(
                title: "Módulo Timer (Event Loop)",
                child: Column(
                  children: [
                    Text(
                      _formatTime(_seconds),
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w200, letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton(
                          label: _isTimerRunning ? "Pausar" : "Iniciar",
                          onPressed: _toggleTimer,
                          icon: _isTimerRunning ? Icons.pause : Icons.play_arrow,
                        ),
                        const SizedBox(width: 12),
                        _buildButton(
                          label: "Reiniciar",
                          onPressed: _resetTimer,
                          icon: Icons.refresh,
                          isSecondary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Módulo 3: Isolate
              _buildCard(
                title: "Módulo Isolate (Heavy Load)",
                child: Column(
                  children: [
                    const Text(
                      "Sumar 1 a 1,000,000,000",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    _isIsolateRunning
                        ? const LinearProgressIndicator()
                        : Text(_isolateResult, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildButton(
                      label: "Ejecutar en Isolate",
                      onPressed: _isIsolateRunning ? null : _runIsolateTask,
                      icon: Icons.memory,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Componentes UI Reutilizables ---

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Divider(height: 30),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
    required IconData icon,
    bool isSecondary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.grey[200] : Colors.black,
        foregroundColor: isSecondary ? Colors.black87 : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}