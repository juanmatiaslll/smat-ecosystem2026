# SMAT - Sistema de Monitoreo de Alerta Temprana

Aplicación móvil desarrollada en **Flutter** con backend en **FastAPI**, orientada al monitoreo de estaciones ambientales y telemetría IoT en tiempo real.

---

# 🚀 Funcionalidades

- Login con JWT y persistencia de sesión
- Consumo de API REST (FastAPI + SQLite)
- Gestión de estaciones (listar y crear)
- Pull-to-refresh para actualización de datos
- Manejo de errores (sin conexión / servidor caído)
- Sesión persistente con SharedPreferences
- Integración IoT mediante telemetría HTTP
- Visualización de lecturas en tiempo real
- Sistema de alertas de inundación
- Actualización automática de datos en Flutter

---

# 📡 Arquitectura del Sistema

```
Sensor IoT (Python)
        ↓
API FastAPI
        ↓
SQLite
        ↓
Aplicación Flutter
```

---

# 🧱 Tecnologías

- Flutter
- FastAPI
- SQLite
- SQLAlchemy
- JWT (Bearer Token)
- Uvicorn
- Python Requests
- SharedPreferences

---

# ⚙️ Backend

## Instalación

```bash
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install fastapi uvicorn sqlalchemy python-multipart python-jose requests
```

## Ejecución

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

# 📱 Frontend Flutter

## Instalación

```bash
flutter pub get
```

## Ejecución

```bash
flutter run
```

---

# 🌐 Configuración

Si ejecutas el backend en otra máquina:

```dart
final String baseUrl = "http://IP_DEL_SERVIDOR:8000";
```

Ejemplo:

```
http://192.168.1.50:8000
```

---

# 🔐 Autenticación

- Método: JWT Bearer Token  
- Endpoint: `/token`

### Header

```
Authorization: Bearer <TOKEN>
```

---

# 📡 API Endpoints

### Seguridad
- POST `/token`

### Estaciones
- GET `/estaciones`
- POST `/estaciones`

### Telemetría IoT
- POST `/lecturas`
- GET `/estaciones/{id}/historial`

---

# 🌡️ Emulación IoT

El sistema incluye un simulador ubicado en:

```
iot_device/sensor_emitter.py
```

Este script simula un sensor de nivel de agua y envía lecturas al backend mediante HTTP con JWT.

---

# ⚡ Sistema de Alertas

- Nivel normal (< 70 cm): envío cada 10 segundos
- Nivel crítico (> 70 cm): envío cada 2 segundos + alerta activa

Mensaje:

```
[ALERTA] Umbral de inundación superado
```

---

# ▶️ Ejecutar Emulador IoT

## Instalar dependencia

```bash
pip install requests
```

## Ejecutar

```bash
cd iot_device
python sensor_emitter.py
```

---

# 📊 Visualización

La app Flutter consume:

```
GET /estaciones/{id}/historial
```

y muestra datos en tiempo real con actualización automática.

---

# 🔄 Resiliencia

- Manejo de errores de conexión
- No bloquea la app si el servidor cae
- Permite reintento manual

---

# 👨‍💻 Autor

**Jose Pacara**  
UNMSM - Ciencia de la Computación