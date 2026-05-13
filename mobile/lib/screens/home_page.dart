import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/estacion.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Estacion> estaciones = [];
  bool loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    cargarEstaciones();
  }

  Future<void> cargarEstaciones() async {
    try {
      setState(() {
        loading = true;
        errorMsg = null;
      });

      final data = await ApiService().fetchEstaciones();

      setState(() {
        estaciones = data;
        loading = false;
      });

    } catch (e) {
      setState(() {
        loading = false;
        estaciones = [];
        errorMsg = e.toString();
      });

      debugPrint("ERROR HOME: $e");

      // 🔥 si es sesión expirada → logout automático
      if (e.toString().contains("Sesión expirada")) {
        await AuthService().logout();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> refrescar() async {
    await cargarEstaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        title: const Text('Estaciones SMAT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: loading
          ? const Center(child: CircularProgressIndicator())

          : errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        size: 60,
                        color: Colors.red,
                      ),
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
                )

              : estaciones.isEmpty
                  ? const Center(
                      child: Text("No hay estaciones registradas"),
                    )
                  : RefreshIndicator(
                      onRefresh: refrescar,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: estaciones.length,
                        itemBuilder: (context, index) {
                          final est = estaciones[index];

                          return ListTile(
                            leading: const Icon(Icons.satellite_alt),
                            title: Text(est.nombre),
                            subtitle: Text(est.ubicacion),
                          );
                        },
                      ),
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