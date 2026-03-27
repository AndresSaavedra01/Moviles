import 'package:flutter/material.dart';

void main() {
  runApp(const UltrakillApp());
}

class UltrakillApp extends StatelessWidget {
  const UltrakillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ultrakill Flutter',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B0000),
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appBarTitle = "Hola, Flutter";

  void _toggleTitle() {
    setState(() {
      _appBarTitle = _appBarTitle == "Hola, Flutter"
          ? "¡ Título cambiado! "
          : "Hola, Flutter";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Título actualizado',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.yellow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView( // Scrolleable
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Center(
                child: Text(
                  "Andres Felipe Saavedra Perez - 230231035",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              /// STACK
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1229490/ss_7a5692d56ec4115252980fed4ad5536d1e401e04.1920x1080.jpg?t=1726657304',
                      fit: BoxFit.cover,
                    ),
                    const Center(
                      child: Text(
                        "ULTRAKILL",
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: "Retimoa",
                          fontWeight: FontWeight.w900,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// SCROLL HORIZONTAL
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _imageBox('assets/ultra1.png'),
                    _imageBox('https://cbu01.alicdn.com/img/ibank/O1CN01SGTp2I1KXHcY930jy_!!1948121173-0-cib.310x310.jpg', isNetwork: true),
                    _imageBox('assets/ultra2.jpg'),
                    _imageBox('assets/ultra3.jpg'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _toggleTitle,
                  icon: const Icon(Icons.sync_alt),
                  label: const Text("Cambiar título"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "INFO",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(),

              /// LISTA
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [

                  ListTile(
                    leading: Icon(Icons.sports_esports, color: Colors.red),
                    title: Text('¿De qué trata?'),
                    subtitle: Text('Máquina que baja al infierno a matar demonios.'),
                  ),

                  ListTile(
                    leading: Icon(Icons.flash_on, color: Colors.yellow),
                    title: Text('Género'),
                    subtitle: Text('FPS retro ultra rápido.'),
                  ),

                  ListTile(
                    leading: Icon(Icons.whatshot, color: Colors.orange),
                    title: Text('Especial'),
                    subtitle: Text('Combos, velocidad y estilo.'),
                  ),

                  ListTile(
                    leading: Icon(Icons.psychology, color: Colors.purple),
                    title: Text('Mecánicas'),
                    subtitle: Text('Parry, movilidad, agresividad.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 Widget reutilizable para imágenes
  Widget _imageBox(String path, {bool isNetwork = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent),
      ),
      child: isNetwork
          ? Image.network(path, width: 120, height: 120, fit: BoxFit.cover)
          : Image.asset(path, width: 120, height: 120, fit: BoxFit.cover),
    );
  }
}