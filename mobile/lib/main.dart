import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';

import 'models/estacion.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SMATApp());
}

class SMATApp extends StatelessWidget {
  const SMATApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMAT Mobile',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    try {
      final token = await AuthService().getToken();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<List<Estacion>> futureEstaciones;
  String? errorMsg;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    errorMsg = null;
    futureEstaciones = ApiService().fetchEstaciones();
  }

  Future<void> refrescar() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
      cargarDatos();
    });

    try {
      final data = await futureEstaciones;

      setState(() {
        isLoading = false;
        if (data.isEmpty) {
          errorMsg = "No hay datos disponibles";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = "Servidor no disponible. Intenta más tarde.";
        futureEstaciones = Future.value([]); // limpia datos viejos
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        title: const Text('SMAT - Monitoreo Móvil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: errorMsg != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    errorMsg!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: refrescar,
                    child: const Text("Reintentar"),
                  )
                ],
              ),
            )
          : FutureBuilder<List<Estacion>>(
              future: futureEstaciones,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 60),
                        const SizedBox(height: 10),
                        const Text(
                          "No se pudo conectar con el servidor",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: refrescar,
                          child: const Text("Reintentar"),
                        )
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No hay estaciones registradas"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: refrescar,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final est = snapshot.data![index];

                      return ListTile(
                        leading: const Icon(Icons.satellite_alt),
                        title: Text(est.nombre),
                        subtitle: Text(est.ubicacion),
                      );
                    },
                  ),
                );
              },
            ),

      // =========================
      // FLOATING BUTTON
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: refrescar,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}