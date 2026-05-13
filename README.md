# SMAT - Sistema de Monitoreo de Alerta Temprana

Aplicación móvil desarrollada en Flutter con backend en FastAPI para el monitoreo de estaciones ambientales en tiempo real.

## 🚀 Funcionalidades
- Login con JWT y persistencia de sesión
- Consumo de API REST (FastAPI + SQLite)
- Gestión de estaciones (listar y crear)
- Pull-to-refresh para actualización de datos
- Manejo de errores (servidor caído / sin conexión)
- Sesión persistente con SharedPreferences

## 🧱 Tecnologías
Flutter, FastAPI, SQLite, JWT (Bearer Token), Uvicorn

## ⚙️ Backend (ejecución)
python -m venv venv  
source venv/bin/activate (Linux/Mac)  
venv\Scripts\activate (Windows)  

pip install fastapi uvicorn sqlalchemy python-multipart  

uvicorn main:app --reload --host 0.0.0.0 --port 8000  

## 📱 Frontend (Flutter)
flutter pub get  
flutter run  

## 🌐 Configuración de red
Si se ejecuta en otra PC o celular cambiar:
final String baseUrl = "http://IP_DEL_SERVIDOR:8000";

Ejemplo:
http://192.168.1.50:8000

## 🔐 Autenticación
Endpoint: /token  
Tipo: JWT Bearer Token  

Header:
Authorization: Bearer TOKEN  

## 📡 Endpoints
GET /estaciones/ → listar estaciones  
POST /estaciones/ → crear estación  

## 🔄 Resiliencia
Si el servidor está apagado la app muestra un mensaje de error, no se bloquea y permite reintentar la conexión.

## 👨‍💻 Autor
Jose Pacara - UNMSM Ciencia de la Computación